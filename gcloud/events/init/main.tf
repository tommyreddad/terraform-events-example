variable "project_id" {
  description = "The project ID"
}

variable "cluster" {
  description = "Name of the cluster"
}

variable "cluster_location" {
  description = "Location of the cluster"
}

resource "null_resource" "events_init" {
  provisioner "local-exec" {
    command = "gcloud beta events init --project=${var.project_id} --cluster=${var.cluster} --cluster-location=${var.cluster_location} --quiet"
  }
}
