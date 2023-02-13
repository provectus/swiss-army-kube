data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}