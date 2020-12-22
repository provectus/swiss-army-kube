# Create namespace jenkins
resource "kubernetes_namespace" "jenkins" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "jenkins"
  repository    = "https://charts.helm.sh/stable"
  chart         = "jenkins"
  version       = "1.27.0"
  namespace     = kubernetes_namespace.jenkins.metadata[0].name
  recreate_pods = true
  timeout       = 1200

  values = [templatefile("${path.module}/values.yml",
    {
      adminPassword                           = var.jenkins_password
      master_ingress_enabled                  = true
      serviceAccountAgent_name                = "jenkins-agent"
      serviceAccountAgent_create              = true
      serviceAccount_name                     = "jenkins-master"
      serviceAccount_create                   = true
      master_ingress_hostName                 = "jenkins.${var.domains[0]}"
      serviceAccount_annotations_rolearn      = aws_iam_role.jenkins_master.arn
      serviceAccountAgent_annotations_rolearn = aws_iam_role.jenkins_agent.arn
      domains                                 = var.domains
    })
  ]
}

# Enabling IAM Roles for Service Accounts
data "aws_iam_policy_document" "jenkins_agent_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:jenkins:jenkins-agent"]
    }

    principals {
      identifiers = [var.cluster_oidc_arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "jenkins_master_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:jenkins:jenkins-master"]
    }

    principals {
      identifiers = [var.cluster_oidc_arn]
      type        = "Federated"
    }
  }
}

# Create role for jenkins agents
resource "aws_iam_role" "jenkins_agent" {
  depends_on = [
    var.module_depends_on
  ]
  assume_role_policy = data.aws_iam_policy_document.jenkins_agent_assume_role_policy.json
  name               = "${var.cluster_name}_jenkins_agent"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Create role for jenkins master
resource "aws_iam_role" "jenkins_master" {
  depends_on = [
    var.module_depends_on
  ]
  assume_role_policy = data.aws_iam_policy_document.jenkins_master_assume_role_policy.json
  name               = "${var.cluster_name}_jenkins_master"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Creating agent policy
resource "aws_iam_policy" "agent_policy" {
  count = var.agent_policy == "" ? 0 : 1
  depends_on = [
    var.module_depends_on
  ]
  name   = "${var.cluster_name}_agent_policy"
  policy = var.agent_policy
}

# Creating master policy
resource "aws_iam_policy" "master_policy" {
  count = var.master_policy == "" ? 0 : 1
  depends_on = [
    var.module_depends_on
  ]
  name   = "${var.cluster_name}_master_policy"
  policy = var.master_policy
}

# Attaching agent_policy policy to role jenkins_agent
resource "aws_iam_role_policy_attachment" "jenkins_agent" {
  count = var.agent_policy == "" ? 0 : 1
  depends_on = [
    var.module_depends_on,
    aws_iam_role.jenkins_agent,
    aws_iam_policy.agent_policy
  ]
  role       = aws_iam_role.jenkins_agent.name
  policy_arn = aws_iam_policy.agent_policy[count.index].arn
}

# Attaching master_policy policy to role jenkins_master
resource "aws_iam_role_policy_attachment" "jenkins_master" {
  count = var.master_policy == "" ? 0 : 1
  depends_on = [
    var.module_depends_on,
    aws_iam_role.jenkins_master,
    aws_iam_policy.master_policy
  ]
  role       = aws_iam_role.jenkins_master.name
  policy_arn = aws_iam_policy.master_policy[count.index].arn
}
