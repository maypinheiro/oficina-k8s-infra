provider "kind" {}

resource "kind_cluster" "oficina" {
  name           = var.cluster_name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 30080
        host_port      = 30080
      }
    }

    node {
      role = "worker"
    }
  }
}

provider "kubectl" {
  config_path      = kind_cluster.oficina.kubeconfig_path
  config_context   = "kind-${var.cluster_name}"
  load_config_file = true
}
