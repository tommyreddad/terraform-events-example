variable "project_id" {
  description = "The project ID"
}

variable "cluster_name" {
  description = "Name of the cluster to install eventing on"
  default     = "events-example-cluster"
}

variable "cluster_location" {
  description = "Location to host the cluster in"
  default     = "us-central1"
}

variable "namespace" {
  description = "Name of the namespace in which to install eventing resources"
  default     = "test-namespace"
}
