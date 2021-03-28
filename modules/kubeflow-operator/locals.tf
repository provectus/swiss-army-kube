locals {
  secret_data = {
    "rds_host"     = var.rds_host
    "rds_port"     = var.rds_port
    "rds_username" = var.rds_username

    "s3_bucket"     = var.s3_bucket_name
    "s3_region"     = data.aws_region.current.name
    "s3_access_key" = var.s3_user_access_key.id
    "s3_secret_key" = var.s3_user_access_key.secret

    "db_name_cache"     = var.db_name_cache
    "db_name_pipelines" = var.db_name_pipelines
    "db_name_metadata"  = var.db_name_metadata
    "db_name_katib"     = var.db_name_katib
  }


  role_to_assume_arn = var.external_secrets_secret_role_arn == "" ? module.iam_assumable_role[0].this_iam_role_arn : var.external_secrets_secret_role_arn

  external_secret_data_rds_password = <<EOT
  - key: ${var.cluster_name}/${var.namespace}/rds_password
    name: rds_password 
  EOT

  external_secret_data = [for key, value in local.secret_data : <<EOT
  - key: ${var.cluster_name}/${var.namespace}/${key}
    name: ${key}
  EOT
  ]

  external_secret_data_string = join("\n", flatten([local.external_secret_data, [local.external_secret_data_rds_password]]))

  external_secret = <<EOT
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: aws-storage-secret
  namespace: ${var.namespace}
spec:
  backendType: secretsManager
  roleArn: ${local.role_to_assume_arn}
  data:
${local.external_secret_data_string}
EOT


  ingress = var.ingress != null ? var.ingress : yamlencode({
    "apiVersion" = "networking.k8s.io/v1beta1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"        = "istio-ingress"
      "namespace"   = "istio-system"
      "annotations" = var.ingress_annotations
      "labels" = {
        "app" = "kubeflow"
      }
    }
    "spec" = {
      "tls" = [
        {
          "hosts" = [
            var.domain
          ]
          "secretName" = "kubeflow-tls-certs"
        }
      ]
      "rules" = [
        {
          "host" = var.domain
          "http" = {
            "paths" = [
              {
                "path" = "/*"
                "backend" = {
                  "serviceName" = "istio-ingressgateway"
                  "servicePort" = 80
                }
              }
            ]
          }
        }
      ]
    }
  })

  namespace_def = var.namespace_def != null ? var.namespace_def : yamlencode({
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = var.namespace
      "labels" = {
        "control-plane"   = "kubeflow"
        "istio-injection" = "enabled"
      }
    }
  })

  issuer = var.issuer != null ? var.issuer : yamlencode({
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "kubeflow-self-signing-issuer"
    }
    "spec" = {
      "selfSigned" = {}
    }
  })

  kfdef = var.kfdef != null ? var.kfdef : yamlencode({
    "apiVersion" = "kfdef.apps.kubeflow.org/v1"
    "kind"       = "KfDef"
    "metadata" = {
      "namespace" = var.namespace
      "name"      = "kubeflow"
    }
    "spec" = {
      "applications" = [
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "application/v3"
            }
          }
          "name" = "application"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/aws/application/istio-stack"
            }
          }
          "name" = "istio-stack"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/aws/application/cluster-local-gateway"
            }
          }
          "name" = "cluster-local-gateway"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/aws/application/istio"
            }
          }
          "name" = "istio"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "metacontroller/base"
            }
          }
          "name" = "metacontroller"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "admission-webhook/bootstrap/overlays/application"
            }
          }
          "name" = "bootstrap"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/kubernetes"
            }
          }
          "name" = "kubeflow-apps"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "knative/installs/generic"
            }
          }
          "name" = "knative"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "kfserving/installs/generic"
            }
          }
          "name" = "kfserving"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "aws/aws-istio-authz-adaptor/base_v3"
            }
          }
          "name" = "aws-istio-authz-adaptor"
        }
      ]
      "repos" = [
        {
          "name" = "manifests"
          "uri"  = "https://github.com/kubeflow/manifests/archive/v1.2-branch.tar.gz"
        }
      ]
      "version" = "v1.2-branch"
    }
  })

  configs = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-storage-workflow-controller-config
  namespace: ${var.namespace}
data:
  config: |
    {
      "executorImage":"gcr.io/ml-pipeline/argoexec:v2.7.5-license-compliance",
      "containerRuntimeExecutor":"docker",
      "workflowDefaults":{
        "metadata":{
          "annotations":{
            "iam.amazonaws.com/role":"${var.pipelines_role_to_assume_role_arn}"
          }
        }
      },
      "artifactRepository":{
        "archiveLogs":true,
        "s3":{
          "bucket":"${var.s3_bucket_name}",
          "keyPrefix":"artifacts",
          "endpoint":"s3.amazonaws.com",
          "insecure":false,
          "region":"${data.aws_region.current.name}",
          "useSDKCreds":true
        }
      }
    }
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-storage-ml-pipeline-config
  namespace: ${var.namespace}
data:
  config.json: |
    {
      "DBConfig":{
        "Host":"${var.rds_host}",
        "Port":"${var.rds_port}",
        "DriverName":"mysql",
        "DataSourceName":"",
        "DBName":"${var.db_name_pipelines}",
        "GroupConcatMaxLen":4194304
      },
      "ObjectStoreConfig":{
        "Host":"s3.amazonaws.com",
        "Region":"${data.aws_region.current.name}",
        "Secure":true,
        "BucketName":"${var.s3_bucket_name}",
        "PipelineFolder":"pipelines",
        "PipelinePath":"pipelines",
        "AccessKey":"",
        "SecretAccessKey":""
      },
      "InitConnectionTimeout":"6m",
      "DefaultPipelineRunnerServiceAccount":"pipeline-runner"
    }

  sample_config.json: |
    [
      {
        "name":"[Demo] XGBoost - Training with Confusion Matrix",
        "description":"[source code](https://github.com/kubeflow/pipelines/blob/master/samples/core/xgboost_training_cm) [GCP Permission requirements](https://github.com/kubeflow/pipelines/blob/master/samples/core/xgboost_training_cm#requirements). A trainer that does end-to-end distributed training for XGBoost models.",
        "file":"/samples/core/xgboost_training_cm/xgboost_training_cm.py.yaml"
      },
      {
        "name":"[Demo] TFX - Taxi Tip Prediction Model Trainer",
        "description":"[source code](https://console.cloud.google.com/mlengine/notebooks/deploy-notebook?q=download_url%3Dhttps%253A%252F%252Fraw.githubusercontent.com%252Fkubeflow%252Fpipelines%252Fmaster%252Fsamples%252Fcore%252Fparameterized_tfx_oss%252Ftaxi_pipeline_notebook.ipynb) [GCP Permission requirements](https://github.com/kubeflow/pipelines/blob/master/samples/contrib/parameterized_tfx_oss#permission). Example pipeline that does classification with model analysis based on a public tax cab dataset.",
        "file":"/samples/core/parameterized_tfx_oss/parameterized_tfx_oss.py.yaml"
      },
      {
        "name":"[Tutorial] Data passing in python components",
        "description":"[source code](https://github.com/kubeflow/pipelines/tree/master/samples/tutorials/Data%20passing%20in%20python%20components) Shows how to pass data between python components.",
        "file":"/samples/tutorials/Data passing in python components/Data passing in python components - Files.py.yaml"
      },
      {
        "name":"[Tutorial] DSL - Control structures",
        "description":"[source code](https://github.com/kubeflow/pipelines/tree/master/samples/tutorials/DSL%20-%20Control%20structures) Shows how to use conditional execution and exit handlers. This pipeline will randomly fail to demonstrate that the exit handler gets executed even in case of failure.",
        "file":"/samples/tutorials/DSL - Control structures/DSL - Control structures.py.yaml"
      }
    ]
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-storage-ml-pipeline-ui-config
  namespace: ${var.namespace}
data:
  "viewer-pod-template.json": |
    {
      "spec":{
        "containers":[
          {
            "env":[
              {
                "name":"AWS_ACCESS_KEY_ID",
                "valueFrom":{
                  "secretKeyRef":{
                    "name":"aws-storage-secret",
                    "key":"s3_access_key"
                  }
                }
              },
              {
                "name":"AWS_SECRET_ACCESS_KEY",
                "valueFrom":{
                  "secretKeyRef":{
                    "name":"aws-storage-secret",
                    "key":"s3_secret_key"
                  }
                }
              },
              {
                "name":"AWS_REGION",
                "valueFrom":{
                  "secretKeyRef":{
                    "name":"aws-storage-secret",
                    "key":"s3_region"
                  }
                }
              }
            ]
          }
        ]
      }
    }
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-storage-ml-pipeline-viewer-template
  namespace: ${var.namespace}
data:
  "viewer-tensorboard-template.json": |
    {
      "metadata":{
        "annotations":{
          "iam.amazonaws.com/role":"${var.pipelines_role_to_assume_role_arn}"
        }
      },
      "spec":{
        "containers":[
          {
            "env":[
              {
                "name":"AWS_REGION",
                "value":"${data.aws_region.current.name}"
              }
            ]
          }
        ]
      }
    }
EOT

}