# Initializes eventing. This performs the following steps:
#  * Install eventing to the knative-eventing and cloud-run-events namespaces.
#  * Create the Google service-accounts for eventing authentication.
#  * Grant the above GSAs their necessary permissions.
#  * Create secrets for those GSAs in the cloud-run-events namespace.
resource "null_resource" "events_init" {
  provisioner "local-exec" {
    command = <<-EOT
    gcloud beta events init \
    --project=${var.project_id} \
    --cluster=${var.cluster} \
    --cluster-location=${var.cluster_location} \
    --quiet
    EOT
  }
  depends_on = [google_container_cluster.example_cluster]
}

# Sets up the namespace `default` for eventing authentication.
resource "null_resource" "namespace_init" {
  provisioner "local-exec" {
    command = <<-EOT
    gcloud beta events namespaces init default \
    --copy-default-secret \
    --project=${var.project_id} \
    --cluster=${var.cluster} \
    --cluster-location=${var.cluster_location} \
    --quiet
    EOT
  }
  depends_on = [null_resource.events_init]
}

# Manages a Broker named `default` in the namespace `default`.
resource "kubernetes_manifest" "broker" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "eventing.knative.dev/v1"
    "kind" = "Broker"
    "metadata" = {
      "name" = "default"
      "namespace" = "default"
      "annotations" = {
        "eventing.knative.dev/broker.class" = "googlecloud"
      }
    }
  }
  depends_on = [null_resource.namespace_init]
}

# Manages a Pub/Sub topic.
resource "google_pubsub_topic" "topic" {
  name = var.topic_name
}

# Manages a CloudPubSubSource named `default` in the namespace `default`, sourcing messages from the above Pub/Sub topic.
resource "kubernetes_manifest" "cloudpubsubsource" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "events.cloud.google.com/v1"
    "kind" = "CloudPubSubSource"
    "metadata" = {
      "name" = "default"
      "namespace" = "default"
    }
    "spec" = {
      "topic" = var.topic_name
      "sink" = {
        "ref" = {
          "apiVersion" = "eventing.knative.dev/v1"
          "kind" = "Broker"
          "name" = "default"
          "namespace" = "default"
        }
      }
    }
  }
  depends_on = [kubernetes_manifest.broker, google_pubsub_topic.topic]
}

# Manages an event-display service in the namespace `default`.
resource "kubernetes_manifest" "event_display" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "serving.knative.dev/v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "event-display"
      "namespace" = "default"
    }
    "spec" = {
      "template" = {
        "metadata" = {
          "annotations" = {
            "autoscaling.knative.dev/minScale" = "1"
            "autoscaling.knative.dev/maxScale" = "1"
          }
          "labels" = {
            "role" = "event-display"
          }
        }
        "spec" = {
          "containers" = [{
            "image" = "gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display"
          }]
        }
      }
    }
  }
}

# Manages a Trigger named `default` in the namespace `default` which filters Pub/Sub messages and sends them to the event-display service.
resource "kubernetes_manifest" "trigger" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "eventing.knative.dev/v1"
    "kind" = "Trigger"
    "metadata" = {
      "name" = "default"
      "namespace" = "default"
    }
    "spec" = {
      "broker" = "default"
      "filter" = {
        "attributes" = {
          "type" = "google.cloud.pubsub.topic.v1.messagePublished"
        }
      }
      "subscriber" = {
        "ref" = {
          "apiVersion" = "v1"
          "kind" = "Service"
          "name" = "event-display"
        }
      }
    }
  }
  depends_on = [kubernetes_manifest.broker, kubernetes_manifest.event_display]
}
