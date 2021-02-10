module "events_init" {
  source = "./events/init"
  project_id = var.project_id
  cluster = var.cluster_name
  cluster_location = var.cluster_location
  module_depends_on = [google_container_cluster.example_cluster]
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
  cluster = var.cluster_name
  cluster_location = var.cluster_location
  module_depends_on = [module.events_init, kubernetes_namespace.namespace]
}

module "events_broker" {
  source = "./events/brokers"
  name = "default"
  namespace = var.namespace
  project_id = var.project_id
  cluster = var.cluster_name
  cluster_location = var.cluster_location
  module_depends_on = [module.events_namespace]
}
