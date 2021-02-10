variable "name" {
  description = "The name of the namespace to initialize"
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

resource "null_resource" "events_namespaces_init" {
  provisioner "local-exec" {
    command = "gcloud beta events namespaces init ${var.name} --copy-default-secret --project=${var.project_id} --cluster=${var.cluster} --cluster-location=${var.cluster_location} --quiet"
  }
  depends_on = [var.module_depends_on]
}
