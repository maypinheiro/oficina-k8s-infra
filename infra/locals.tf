locals {
  k8s_dir = "${path.module}/../k8s"

  namespace_manifest_files = ["namespace.yaml"]

  base_manifest_files = [
    "configmap.yaml",
    "secret.yaml",
    "metrics-server.yaml",
    "postgres.yaml"
  ]

  app_manifest_files = [
    "api.yaml",
    "api-pdb.yaml",
    "hpa.yaml"
  ]
}
