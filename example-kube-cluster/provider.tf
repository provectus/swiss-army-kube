provider "aws" {
  version = ">= 2.33.0"
  region  = var.region
}

provider "kubernetes" {
  host                   = module.infrastructure.cluster_endpoint
  cluster_ca_certificate = base64decode(module.infrastructure.cluster_ca)
  token                  = module.infrastructure.cluster_token
  load_config_file       = false
  version                = "~> 1.10"
}