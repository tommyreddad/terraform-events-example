variable "name" {
  description = "The name of the broker"
}

variable "namespace" {
  description = "Namespace in which the broker lives"
}

variable "project_id" {
  description = "The project ID"
}

variable "cluster" {
  description = "Name of the cluster to install eventing on"
}

variable "cluster_location" {
  description = "Location to host the cluster in"
}

/* This is a hack since Terraform 0.12 does not support module depends_on: https://github.com/hashicorp/terraform/issues/10462
Can we use Terraform 0.13 or 0.14? */
variable "module_depends_on" {
  type    = any
  default = null
}
/* Hack ends here */

resource "null_resource" "events_brokers" {
  triggers = {
    name = var.name
    namespace = var.namespace
    project_id = var.project_id
    cluster = var.cluster
    cluster_location = var.cluster_location
  }
  provisioner "local-exec" {
    command = "gcloud beta events brokers create ${self.triggers.name} --namespace=${self.triggers.namespace} --project=${self.triggers.project_id} --cluster=${self.triggers.cluster} --cluster-location=${self.triggers.cluster_location} --quiet"
  }
  provisioner "local-exec" {
    when = destroy
    command = "gcloud beta events brokers delete ${self.triggers.name} --namespace=${self.triggers.namespace} --project=${self.triggers.project_id} --cluster=${self.triggers.cluster} --cluster-location=${self.triggers.cluster_location} --quiet"
  }
  depends_on = [var.module_depends_on]
}
