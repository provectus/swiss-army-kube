

locals {

  role_to_assume_arn = var.external_secrets_secret_role_arn == "" ? module.iam_assumable_role[0].this_iam_role_arn : var.external_secrets_secret_role_arn

  name = "mlflow"
  namespace_def = var.namespace_def != null ? var.namespace_def : yamlencode({
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = var.namespace
      "labels" = {
        "control-plane"   = "kubeflow"
        "istio-injection" = "enabled"
      }
      # "annotations" = {
      #   "iam.amazonaws.com/permitted" = var.external_secrets_role_arn //restrict this namespace to only being able to assume this arn (wildcards are also possible, e.g. iam.amazonaws.com/permitted: "arn:aws:iam::123456789012:role/.*")
      # }
    }
  })


  mlflow_def = var.mlflow_def != null ? var.mlflow_def : <<EOT
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: mlflow-secret
  namespace: ${var.namespace}
spec:
  backendType: secretsManager
  roleArn: ${local.role_to_assume_arn}
  data:
    - key: ${var.cluster_name}/${var.namespace}/rds_username
      name: rds_username    
    - key: ${var.cluster_name}/${var.namespace}/rds_password
      name: rds_password
---
apiVersion: batch/v1
kind: Job
metadata:
  name: create-mlflow-database
  namespace: ${var.namespace}
spec:
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
    spec:
      containers:
      - name: create-mlflow-database
        image: public.ecr.aws/v5l9k3w9/utils/mysql-db-creator:latest
        env:
        - name: HOST
          value: ${var.rds_host}
        - name: PORT
          value: ${var.rds_port}
        - name: USERNAME
          valueFrom:
            secretKeyRef:
              name: mlflow-secret
              key: rds_username
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: mlflow-secret
              key: rds_password
        - name: DATABASE
          value: ${var.db_name}

      restartPolicy: Never
  backoffLimit: 5
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow
  labels:
    app: mlflow
  namespace: ${var.namespace}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mlflow
  template:
    metadata:
      labels:
        app: mlflow
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
        - name: mlflow
          securityContext: {}
          image: "public.ecr.aws/v5l9k3w9/mlflow-server:latest"
          imagePullPolicy: Always
          args:
            - --host=0.0.0.0
            - --port=5000
            - --backend-store-uri="mysql://$(rds_username):$(rds_password)@${var.rds_host}:${var.rds_port}/mlflow"
            - --default-artifact-root=s3://${var.s3_bucket_name}/modeling/experiments
          envFrom:         
          - secretRef:
              name: mlflow-secret
          ports:
            - name: http
              containerPort: 5000
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources: {}
---
apiVersion: v1
kind: Service
metadata:
  name: mlflow
  namespace: ${var.namespace}
spec:
  selector:
    app: mlflow
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 5000

---
kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: mlflow
  namespace: kubeflow
spec:
  gateways:
    - kubeflow-gateway
  hosts:
    - '*'
  http:
    - match:
        - uri:
            prefix: /mlflow
      rewrite:
        uri: /
      route:
        - destination:
            host: mlflow.mlflow.svc.cluster.local
            port:
              number: 80
      timeout: 300s
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mlflow
  namespace: ${var.namespace}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  labels:
    app: mlflow
  name: mlflow
  namespace: ${var.namespace}
rules: []
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  labels:
    app: mlflow
  name: mlflow
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: mlflow
subjects:
- kind: ServiceAccount
  name: mlflow
EOT
}