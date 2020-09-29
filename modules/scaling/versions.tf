terraform {
  required_version = ">= 0.12, < 0.14"

  required_providers {
    aws        = ">= 2.0, < 4.0"
    helm       = ">= 0.10, < 2.0"
    kubernetes = ">= 1.11"
  }
}
