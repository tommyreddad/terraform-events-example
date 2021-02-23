# Initializes eventing. This performs the following steps:
#  * Install eventing to the knative-eventing and cloud-run-events namespaces.
#  * Create the Google service-accounts for eventing authentication.
#  * Grant the above GSAs their necessary permissions.
#  * Create secrets for those GSAs in the cloud-run-events namespace.
resource "null_resource" "events_init" {
  triggers = {
    project_id = var.project_id
    cluster = var.cluster
    cluster_location = var.cluster_location
  }
  provisioner "local-exec" {
    command = <<-EOT
    gcloud beta events init \
    --project=${self.triggers.project_id} \
    --cluster=${self.triggers.cluster} \
    --cluster-location=${self.triggers.cluster_location} \
    --quiet
    EOT
  }
  depends_on = [google_container_cluster.example_cluster]
}

# Sets up the namespace `default` for eventing authentication.
resource "null_resource" "namespace_init" {
  triggers = {
    name = "default"
    project_id = var.project_id
    cluster = var.cluster
    cluster_location = var.cluster_location
  }
  provisioner "local-exec" {
    command = <<-EOT
    gcloud beta events namespaces init ${self.triggers.name} \
    --copy-default-secret \
    --project=${self.triggers.project_id} \
    --cluster=${self.triggers.cluster} \
    --cluster-location=${self.triggers.cluster_location} \
    --quiet
    EOT
  }
  depends_on = [null_resource.events_init]
}

# Manages a Broker named `default` in the namespace `default`.
resource "null_resource" "broker" {
  triggers = {
    name = "default"
    namespace = "default"
    project_id = var.project_id
    cluster = var.cluster
    cluster_location = var.cluster_location
  }
  provisioner "local-exec" {
    command = <<-EOT
    gcloud beta events brokers create ${self.triggers.name} \
    --namespace=${self.triggers.namespace} \
    --project=${self.triggers.project_id} \
    --cluster=${self.triggers.cluster} \
    --cluster-location=${self.triggers.cluster_location} \
    --quiet
    EOT
  }
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
    gcloud beta events brokers delete ${self.triggers.name} \
    --namespace=${self.triggers.namespace} \
    --project=${self.triggers.project_id} \
    --cluster=${self.triggers.cluster} \
    --cluster-location=${self.triggers.cluster_location} \
    --quiet
    EOT
  }
  depends_on = [null_resource.namespace_init]
}

# Manages an event-display service in the namespace `default`.
resource "null_resource" "event_display" {
  triggers = {
    name = "event-display"
    namespace = "default"
    image = "gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display"
    project_id = var.project_id
    cluster = var.cluster
    cluster_location = var.cluster_location
  }
  provisioner "local-exec" {
    command = <<-EOT
    gcloud run deploy ${self.triggers.name} \
    --namespace=${self.triggers.namespace} \
    --image=${self.triggers.image} \
    --min-instances=1 \
    --max-instances=1 \
    --labels=role=${self.triggers.name} \
    --project=${self.triggers.project_id} \
    --cluster=${self.triggers.cluster} \
    --cluster-location=${self.triggers.cluster_location} \
    --quiet
    EOT
  }
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
    gcloud run services delete ${self.triggers.name} \
    --namespace=${self.triggers.namespace} \
    --project=${self.triggers.project_id} \
    --cluster=${self.triggers.cluster} \
    --cluster-location=${self.triggers.cluster_location} \
    --quiet
    EOT
  }
  depends_on = [google_container_cluster.example_cluster]
}

# Manages a Pub/Sub topic.
resource "google_pubsub_topic" "topic" {
  name = var.topic_name
}

# Manages a Pub/Sub Trigger named `default` in the namespace `default`.
resource "null_resource" "trigger" {
  triggers = {
    name = "default"
    namespace = "default"
    topic = var.topic_name
    target_service = "event-display"
    project_id = var.project_id
    cluster = var.cluster
    cluster_location = var.cluster_location
  }
  provisioner "local-exec" {
    command = <<-EOT
    gcloud beta events triggers create ${self.triggers.name} \
    --namespace=${self.triggers.namespace} \
    --type=google.cloud.pubsub.topic.v1.messagePublished \
    --parameters='topic=${self.triggers.topic}' \
    --target-service=${self.triggers.target_service} \
    --project=${self.triggers.project_id} \
    --cluster=${self.triggers.cluster} \
    --cluster-location=${self.triggers.cluster_location} \
    --quiet
    EOT
  }
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
    gcloud beta events triggers delete ${self.triggers.name} \
    --namespace=${self.triggers.namespace} \
    --project=${self.triggers.project_id} \
    --cluster=${self.triggers.cluster} \
    --cluster-location=${self.triggers.cluster_location} \
    --quiet
    EOT
  }
  depends_on = [null_resource.broker, google_pubsub_topic.topic, null_resource.event_display]
}
