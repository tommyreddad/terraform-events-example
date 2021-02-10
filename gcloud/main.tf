resource "null_resource" "events_init" {
  provisioner "local-exec" {
    command = "gcloud beta events init --project=${var.project_id} --cluster=${var.cluster_name} --cluster-location=${var.cluster_location} --quiet"
  }
  depends_on = [google_container_cluster.example_cluster]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
  depends_on = [google_container_cluster.example_cluster]
}

resource "null_resource" "events_namespace" {
  provisioner "local-exec" {
    command  = "gcloud beta events namespaces init ${var.namespace} --copy-default-secret --project=${var.project_id} --cluster=${var.cluster_name} --cluster-location=${var.cluster_location} --quiet"
  }
  depends_on = [null_resource.events_init, kubernetes_namespace.namespace]
}

resource "null_resource" "events_broker" {
  triggers = {
    namespace        = var.namespace
    project_id       = var.project_id
    cluster_name     = var.cluster_name
    cluster_location = var.cluster_location
  }
  provisioner "local-exec" {
    command  = "gcloud beta events brokers create default --namespace=${self.triggers.namespace} --project=${self.triggers.project_id} --cluster=${self.triggers.cluster_name} --cluster-location=${self.triggers.cluster_location} --quiet"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud beta events brokers delete default --namespace=${self.triggers.namespace} --project=${self.triggers.project_id} --cluster=${self.triggers.cluster_name} --cluster-location=${self.triggers.cluster_location} --quiet"
  }
  depends_on = [null_resource.events_init, null_resource.events_namespace]
}
