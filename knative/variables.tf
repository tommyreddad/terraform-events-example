variable "project_id" {
  description = "The project ID"
}

variable "cluster" {
  description = "Name of the cluster to install eventing on"
  default     = "events-example-cluster-knative"
}

variable "cluster_location" {
  description = "Location to host the cluster in"
  default     = "us-central1-c"
}

variable "topic_name" {
  description = "Name of the Pub/Sub topic to send events through"
  default     = "test-topic-knative"
}
