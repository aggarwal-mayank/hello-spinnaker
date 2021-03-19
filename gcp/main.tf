terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.45.0"
    }
  }
  required_version = "~> 0.14.0"
}

provider "google" {
  project = var.project
}

module "cluster" {
  source = "./modules/cluster"
  master_version = var.master_version
  node_version   = var.node_version
  region         = var.region
  zones          = var.zones
  depends_on = [ module.project-services ]
}

module "halyard" {
  source = "./modules/halyard"
  zone   = var.zones[0] 
  depends_on = [ module.project-services ]
}

module "storage" {
  source = "./modules/storage"
}

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "10.1.1"

  project_id                  = var.project

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com"
  ]
}


