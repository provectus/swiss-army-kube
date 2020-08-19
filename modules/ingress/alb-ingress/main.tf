# Create namespace ingress-system
resource "kubernetes_namespace" "ingress-system" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "ingress-system"
  }
}

data "aws_eks_cluster" "this" {
  depends_on = [
    var.module_depends_on
  ]
  name = var.cluster_name
}

#Global helm chart repo
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}


# Create role for alb-ingress
resource "aws_iam_policy" "alb-ingress" {
  depends_on = [
    var.module_depends_on
  ]
  name               = "${var.cluster_name}-alb-ingress-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "wafv2:GetWebACL",
        "wafv2:GetWebACLForResource",
        "wafv2:AssociateWebACL",
        "wafv2:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "shield:DescribeProtection",
        "shield:GetSubscriptionState",
        "shield:DeleteProtection",
        "shield:CreateProtection",
        "shield:DescribeSubscription",
        "shield:ListProtections"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create role for alb-ingress
resource "aws_iam_role" "alb-ingress" {
  depends_on = [
    var.module_depends_on
  ]
  name               = "${var.cluster_name}_alb-ingress"
  description        = "Role for alb-ingress"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}:sub": "system:serviceaccount:ingress-system:*"
        }
      },
      "Principal": {
        "Federated": "arn:aws:iam::481193184231:oidc-provider/${replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach policy alb-ingress to role alb-ingress
resource "aws_iam_role_policy_attachment" "alb-ingress" {
  depends_on = [
    var.module_depends_on,
    aws_iam_policy.alb-ingress
  ]
  role       = aws_iam_role.alb-ingress.name
  policy_arn = aws_iam_policy.alb-ingress.arn
}

resource "helm_release" "alb-ingress" {
  depends_on = [
    var.module_depends_on,
    aws_iam_role.alb-ingress
  ]
  name       = "alb"
  repository = data.helm_repository.incubator.metadata[0].name
  chart      = "aws-alb-ingress-controller"
  namespace  = "ingress-system"

  values = [
    file("${path.module}/values/values.yaml"),
  ]

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsVpcID"
    value = var.vpc_id
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }    

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.alb-ingress.arn}"
  }
}

# Deploy ingress for connect alb and nginx
#resource "null_resource" "alb-nginx-ingress" {
#  depends_on = [
#    var.module_depends_on,
#    helm_release.alb-ingress
#  ]
#  provisioner "local-exec" {
#    command = "kubectl --kubeconfig ${var.config_path} create -f ${path.module}/values/ingress-nginx.yaml"
#  }
#}