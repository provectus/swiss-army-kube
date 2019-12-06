#resource "aws_iam_policy" "cluster_autoscaler" {
#  name        = "cluster_autoscaler"
#  path        = "/"
#  description = "Kubernetes autoscaler policy"
#
#  policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Action": [
#                "autoscaling:DescribeAutoScalingGroups",
#                "autoscaling:DescribeAutoScalingInstances",
#                "autoscaling:DescribeLaunchConfigurations",
#                "autoscaling:SetDesiredCapacity",
#                "autoscaling:DescribeTags",
#                "autoscaling:TerminateInstanceInAutoScalingGroup"
#            ],
#            "Resource": "*"
#        }
#    ]
#}
#EOF
#}

# Set admin arns
resource "null_resource" "map_users" {
  count = length(var.admin_arns)

  triggers = {
    user_arn = var.admin_arns[count.index]
    username = "{{UserID}}"
    group    = "system:masters"
  }
}
