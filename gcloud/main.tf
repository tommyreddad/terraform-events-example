module "events_init" {
  source = "./events/init"
  project_id = var.project_id
  cluster = var.cluster
  cluster_location = var.cluster_location
  depends_on = [google_container_cluster.example_cluster]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
  depends_on = [google_container_cluster.example_cluster]
}

module "events_namespace" {
  source = "./events/namespaces"
  name = var.namespace
  project_id = var.project_id
  cluster = var.cluster
  cluster_location = var.cluster_location
  depends_on = [module.events_init, kubernetes_namespace.namespace]
}

module "events_broker" {
  source = "./events/brokers"
  create_cmd_body = "default --namespace=${var.namespace}"
  destroy_cmd_body = "default --namespace=${var.namespace}"
  project_id = var.project_id
  cluster = var.cluster
  cluster_location = var.cluster_location
  depends_on = [module.events_namespace]
}

module "events_trigger" {
  source = "./events/triggers"
  create_cmd_body = "default --namespace=${var.namespace} --type some-event-type --custom-type --target-service=http://something.svc.cluster.local/"
  destroy_cmd_body = "default --namespace=${var.namespace}"
  project_id = var.project_id
  cluster = var.cluster
  cluster_location = var.cluster_location
  depends_on = [module.events_broker]
}
