resource "google_container_cluster" "example_cluster" {
  provider = google-beta
  project  = var.project_id
  name     = var.cluster
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
    machine_type = "e2-standard-4"
  }

  addons_config {
    cloudrun_config {
      disabled = false
    }
  }

  depends_on = [module.enabled_google_apis]
}

provider "kubernetes-alpha" {
  server_side_planning   = true
  host                   = "https://${google_container_cluster.example_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.example_cluster.master_auth.0.cluster_ca_certificate)
}
