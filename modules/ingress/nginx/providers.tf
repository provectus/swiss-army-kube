provider "helm" {
  kubernetes {
    config_path = var.config_path
  }
}