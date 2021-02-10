locals {
  kubeconfig_path = abspath("${path.module}/${var.kubeconfig_path}")
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

provider "kubernetes" {
  config_path = local.kubeconfig_path
}

resource "google_container_cluster" "example_cluster" {
  provider = google-beta
  project  = var.project_id
  name     = var.cluster_name
  location = var.cluster_location

  initial_node_count = 3
  release_channel {
    channel = "RAPID"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    machine_type = "n1-standard-4"
  }

  addons_config {
    cloudrun_config {
      disabled = false
    }
  }

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  depends_on = [module.enabled_google_apis]
}

resource "null_resource" "init" {
  provisioner "local-exec" {
    command = "gcloud beta container clusters get-credentials ${var.cluster_name} --region ${var.cluster_location} --project ${var.project_id}"
    environment = {
      KUBECONFIG = local.kubeconfig_path
    }
  }
  provisioner "local-exec" {
    command = "gcloud config set run/cluster ${var.cluster_name}"
    environment = {
      KUBECONFIG = local.kubeconfig_path
    }
  }
  provisioner "local-exec" {
    command = "gcloud config set run/cluster_location ${var.cluster_location}"
    environment = {
      KUBECONFIG = local.kubeconfig_path
    }
  }
  provisioner "local-exec" {
    command = "gcloud config set run/platform gke"
    environment = {
      KUBECONFIG = local.kubeconfig_path
    }
  }
  provisioner "local-exec" {
    command = "gcloud config set project ${var.project_id}"
    environment = {
      KUBECONFIG = local.kubeconfig_path
    }
  }
  depends_on = [google_container_cluster.example_cluster]
}

resource "null_resource" "init_eventing" {
  provisioner "local-exec" {
    command = "gcloud beta events init --quiet"
    environment = {
      KUBECONFIG = local.kubeconfig_path
    }
  }
  depends_on = [null_resource.init]
}
