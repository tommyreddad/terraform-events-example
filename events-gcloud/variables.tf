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

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  default = ".kube/config"
}
