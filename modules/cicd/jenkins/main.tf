#Global helm chart repo
data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "helm_release" "jenkins" {
  depends_on = [
    var.module_depends_on,
    aws_iam_role_policy_attachment.jenkins_agent
  ]   
  
  name          = "jenkins"
  repository    = data.helm_repository.stable.metadata[0].name
  chart         = "jenkins"
  namespace     = "jenkins"
  recreate_pods = true

  set {
    name  = "master.adminPassword"
    value = var.jenkins_password
  }

  set {
    name  = "master.ingress.enabled"
    value = "true"
  }

  set {
    name  = "serviceAccountAgent.name"
    value = "jenkins_agent"
  }

  set {
    name  = "serviceAccountAgent.create"
    value = true
  }

  set_string {
    name  = "serviceAccountAgent.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.jenkins_agent.arn}"
  }

//TODO: fix it for multi domains
  set {
      name  = "master.ingress.hostName"
      value = "jenkins.${var.domains[0]}"
  }

  dynamic "set" {
    for_each = var.domains
    content {  
      name  = "master.ingress.tls[${set.key}].secretName"
      value = "jenkins-${set.key}-tls"
    }
  }
  dynamic "set" {
    for_each = var.domains
    content {  
      name  = "master.ingress.tls[${set.key}].hosts[0]"
      value = "jenkins.${set.value}"
    }
  }

  values = [
    file("${path.module}/values.yml")
  ]
}

# Enabling IAM Roles for Service Accounts
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "jenkins_agent_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:jenkins:jenkins_agent"]
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

# Attach S3 policy to role jenkins_agent
resource "aws_iam_role_policy_attachment" "jenkins_agent" {
  depends_on = [
    var.module_depends_on,
    aws_iam_role.jenkins_agent
  ]
  role       = aws_iam_role.jenkins_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}