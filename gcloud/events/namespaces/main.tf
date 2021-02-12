variable "name" {
  description = "The name of the namespace to initialize"
}

variable "project_id" {
  description = "The project ID"
}

variable "cluster" {
  description = "Name of the cluster"
}

variable "cluster_location" {
  description = "Location of the cluster"
}

resource "null_resource" "events_namespaces_init" {
  provisioner "local-exec" {
    command = "gcloud beta events namespaces init ${var.name} --copy-default-secret --project=${var.project_id} --cluster=${var.cluster} --cluster-location=${var.cluster_location} --quiet"
  }
}
