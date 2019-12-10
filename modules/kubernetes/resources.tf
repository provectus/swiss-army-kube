# Set admin arns
resource "null_resource" "map_users" {
  count = length(var.admin_arns)

  triggers = {
    user_arn = var.admin_arns[count.index]
    username = "{{UserID}}"
    group    = "system:masters"
  }
}

# Enabling IAM Roles for Service Accounts 

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_role" "cluster" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = var.cluster_name
}
