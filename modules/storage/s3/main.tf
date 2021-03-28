resource "aws_s3_bucket" "kubeflow" {

  bucket = var.s3_bucket_name
  tags   = var.tags

  # lifecycle {
  #   prevent_destroy = false
  # }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


// create read-write user for S3 bucket
resource "aws_iam_user" "s3_user" {
  name = "${var.cluster_name}-s3-user"
  path = "/system/"
}

resource "aws_iam_access_key" "s3_user" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user" {
  name = "${var.cluster_name}-s3-user-policy"
  user = aws_iam_user.s3_user.name

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["${aws_s3_bucket.kubeflow.arn}"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["${aws_s3_bucket.kubeflow.arn}/*"]
        }
    ]
}

EOT
}

// create read-write role for S3 bucket




resource "aws_iam_policy" "s3_role" {
  name = "${var.cluster_name}-s3-role-policy"

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["${aws_s3_bucket.kubeflow.arn}"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["${aws_s3_bucket.kubeflow.arn}/*"]
        }
    ]
}
EOT
}

module "s3_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.0"

  trusted_role_arns = var.trusted_role_arns

  create_role = true

  role_name = "${var.cluster_name}-s3-role"

  role_requires_mfa = false

  custom_role_policy_arns = [
    aws_iam_policy.s3_role.arn
  ]

  number_of_custom_role_policy_arns = 1
  tags                              = var.tags
}




