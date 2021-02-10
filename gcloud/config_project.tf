data "google_client_config" "default" {}

provider "google" {
  version = "~> 3.10"
  project = var.project_id
  region  = var.cluster_location
}

provider "google-beta" {
  version = "~> 3.10"
  project = var.project_id
  region  = var.cluster_location
}

module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 8.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "cloudapis.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
  ]
}
