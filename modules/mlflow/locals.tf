resource "aws_secretsmanager_secret" "rds_username" {
  name = "mlflow/rds_username"
}
resource "aws_secretsmanager_secret_version" "rds_user" {
  secret_id     = aws_secretsmanager_secret.rds_user.id
  secret_string = var.rds_username
}
resource "aws_secretsmanager_secret" "rds_password" {
  name = "mlflow/rds_password"
}
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = var.rds_password
}


locals {  
  namespace = var.namespace != null ? var.namespace : yamlencode({
      "apiVersion" = "v1"
      "kind"       = "Namespace"
      "metadata" = {
        "name" = "mlflow"
        "labels" = {
          "control-plane"   = "kubeflow"
          "istio-injection" = "enabled"
        }
      }
    })


  mlflow_def = var.mlflow_def != null ? var.mlflow_def : <<EOT
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: mlflow-secret
spec:
  backendType: secretsManager
  data:
    - key: mlflow/rds_username
      name: rds_username    
    - key: mlflow/rds_password
      name: rds_password
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow
  labels:
    app: mlflow
  namespace: mlflow
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
          image: "kschriek/mlflow-server:latest"
          imagePullPolicy: Always
          args:
            - --host=0.0.0.0
            - --port=5000
            - --backend-store-uri=mysql://$(rds_username):$(rds_password)@${var.rds_host}:${var.rds_port}/mlflow
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
  namespace: mlflow
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
  namespace: mlflow
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  labels:
    app: mlflow
  name: mlflow
  namespace: mlflow
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