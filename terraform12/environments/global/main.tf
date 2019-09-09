terraform {
  backend "s3" {
    bucket         = "opsdata"
    key            = "terraform/states/global/iam.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "TerraformStateLocks"
  }
  required_version = ">= 0.12.0"
}

provider "aws" {
  region  = "us-east-2"
  version = "2.21.0"
}

### Environment independent templates

### Example
### User: system-user
resource "aws_iam_user" "system_user" {
  name = "system-user"
}

resource "aws_iam_user_policy" "system-user" {
  name = "system_user_s3_access"
  user = "${aws_iam_user.system_user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListingOfUserFolder",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::BUCKET_NAME"
      ],
      "Condition":{"StringLike":{"s3:prefix":["user/*"]}}
    },
    {
      "Sid": "AllowAllS3ActionsInUserFolder",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": ["arn:aws:s3:::BUCKET_NAME/user/*"]
    }
  ]
}
EOF
}
