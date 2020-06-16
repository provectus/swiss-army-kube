resource "aws_s3_bucket" "argo-artifacts" {
  depends_on = [
    var.module_depends_on
  ]
  bucket = "${var.cluster_name}-argo-artifacts"
  acl    = "private"
  region = var.aws_region

  tags = {
    Name        = "${var.cluster_name}-argo-artifacts"
    Environment = var.environment
    Project     = var.project
    Team        = "DevOps"
    Description = "for argo artifacts in kubernetes"
  }
}

output "aws_s3_bucket" {
  value = aws_s3_bucket.argo-artifacts.bucket
}

output "artifacts" {
  value = aws_s3_bucket.argo-artifacts
}

### User: system-argo-artifacts
resource "aws_iam_user" "system_argo_artifacts" {
  name = "system-argo-artifacts-${var.cluster_name}"
}

resource "aws_iam_user_policy" "system-argo-artifacts" {
  name = "system_argo_artifacts_s3_access-${var.cluster_name}"
  user = aws_iam_user.system_argo_artifacts.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ActionsInBucket",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetBucketLocation"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.argo-artifacts.bucket}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "system_argo_artifacts" {
  user = aws_iam_user.system_argo_artifacts.name
}



resource "kubernetes_secret" "argo-artifacts" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name      = "argo-artifacts"
    namespace = "argo-events"
  }

  data = {
    accesskey = "${aws_iam_access_key.system_argo_artifacts.id}"
    secretkey = "${aws_iam_access_key.system_argo_artifacts.secret}"
  }

  type = "Opaque"
}


# resource "helm_release" "argo-artifacts" {

#   name          = "argo-artifacts"
#   repository    = "stable"
#   chart         = "minio"
#   version       = "0.14.0"
#   namespace     = "oauth2"
#   recreate_pods = true

#   values = [
#     "${file("${path.module}/values.yml")}",
#   ]

#   set {
#     name  = "extraArgs.cookie-domain"
#     value = ".${var.domain}"
#   }

# }

# helm install stable/minio --name argo-artifacts --set service.type=LoadBalancer


# $ aws s3 mb s3://$mybucket [--region xxx]
# $ aws iam create-user --user-name $mybucket-user
# $ aws iam put-user-policy --user-name $mybucket-user --policy-name $mybucket-policy --policy-document file://policy.json
# $ aws iam create-access-key --user-name $mybucket-user > access-key.json

