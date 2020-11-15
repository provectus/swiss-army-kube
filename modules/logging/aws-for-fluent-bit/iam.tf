data "aws_iam_policy_document" "aws_for_fluent_bit_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.namespace}:${var.service_account_name}"]
    }

    principals {
      identifiers = [var.cluster_oidc_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_for_fluent_bit_iam_role" {
  name               = "${var.cluster_name}-aws-for-fluent-bit"
  assume_role_policy = data.aws_iam_policy_document.aws_for_fluent_bit_assume_role_policy.json

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  count = var.cloudwatch_enabled ? 1 : 0

  name   = "${var.cluster_name}-aws-for-fluent-bit-cloudwatch-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:PutRetentionPolicy",
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:${var.cloudwatch_log_group_name}:log-stream:*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_role_policy_attachment" {
  count = var.cloudwatch_enabled ? 1 : 0

  role       = aws_iam_role.aws_for_fluent_bit_iam_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy[count.index].arn
}

resource "aws_iam_policy" "firehose_policy" {
  count = var.firehose_enabled ? 1 : 0
  name  = "${var.cluster_name}-aws-for-fluent-bit-firehose-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ],
      "Resource": [
        "arn:aws:firehose:${var.aws_region}:${var.aws_account}:deliverystream/${var.firehose_delivery_stream}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "firehose_role_policy_attachment" {
  count = var.firehose_enabled ? 1 : 0

  role       = aws_iam_role.aws_for_fluent_bit_iam_role.name
  policy_arn = aws_iam_policy.firehose_policy[count.index].arn
}

resource "aws_iam_policy" "kinesis_policy" {
  count = var.kinesis_enabled ? 1 : 0
  name  = "${var.cluster_name}-aws-for-fluent-bit-kinesis-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ],
      "Resource": [
        "arn:aws:kinesis:${var.aws_region}:${var.aws_account}:stream/${var.kinesis_stream}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "kinesis_role_policy_attachment" {
  count = var.kinesis_enabled ? 1 : 0

  role       = aws_iam_role.aws_for_fluent_bit_iam_role.name
  policy_arn = aws_iam_policy.kinesis_policy[count.index].arn
}