data "kubectl_file_documents" "namespace" {
  for_each = toset(local.namespace_manifest_files)
  content  = replace(file("${local.k8s_dir}/${each.value}"), "namespace: oficina", "namespace: ${var.namespace}")
}

data "kubectl_file_documents" "base" {
  for_each = toset(local.base_manifest_files)
  content  = replace(file("${local.k8s_dir}/${each.value}"), "namespace: oficina", "namespace: ${var.namespace}")
}

data "kubectl_file_documents" "app" {
  for_each = toset(local.app_manifest_files)
  content  = replace(file("${local.k8s_dir}/${each.value}"), "namespace: oficina", "namespace: ${var.namespace}")
}

resource "kubectl_manifest" "namespace" {
  for_each  = merge([for document in data.kubectl_file_documents.namespace : document.manifests]...)
  yaml_body = each.value

  depends_on = [kind_cluster.oficina]
}

resource "kubectl_manifest" "base" {
  for_each  = merge([for document in data.kubectl_file_documents.base : document.manifests]...)
  yaml_body = each.value

  depends_on = [kubectl_manifest.namespace]
}

resource "kubectl_manifest" "app" {
  for_each  = var.deploy_app ? merge([for document in data.kubectl_file_documents.app : document.manifests]...) : {}
  yaml_body = each.value

  depends_on = [kubectl_manifest.base]
}
