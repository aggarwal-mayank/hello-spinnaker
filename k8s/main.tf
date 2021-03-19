terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
  }
  required_version = "~> 0.14.0"
}

provider "kubernetes" {
}

module "spinnaker" {
  source = "./modules/spinnaker"
}

