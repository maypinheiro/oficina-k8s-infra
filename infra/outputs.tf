output "cluster_name" {
  description = "Cluster Kubernetes provisionado."
  value       = kind_cluster.oficina.name
}

output "kubeconfig_path" {
  description = "Arquivo kubeconfig gerado para o cluster Kind."
  value       = kind_cluster.oficina.kubeconfig_path
}

output "namespace" {
  description = "Namespace reservado para os manifestos da aplicacao."
  value       = var.namespace
}

output "kube_context" {
  description = "Contexto kubectl gerado pelo cluster Kind."
  value       = "kind-${var.cluster_name}"
}
