variable "create_cmd_body" {
  description = ""
}

variable "destroy_cmd_body" {
  description = ""
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

resource "null_resource" "events_brokers" {
  triggers = {
    create_cmd_body = var.create_cmd_body
    destroy_cmd_body = var.destroy_cmd_body
    project_id = var.project_id
    cluster = var.cluster
    cluster_location = var.cluster_location
  }
  provisioner "local-exec" {
    command = "gcloud beta events brokers create ${self.triggers.create_cmd_body} --project=${self.triggers.project_id} --cluster=${self.triggers.cluster} --cluster-location=${self.triggers.cluster_location} --quiet"
  }
  provisioner "local-exec" {
    when = destroy
    command = "gcloud beta events brokers delete ${self.triggers.destroy_cmd_body} --project=${self.triggers.project_id} --cluster=${self.triggers.cluster} --cluster-location=${self.triggers.cluster_location} --quiet"
  }
}
