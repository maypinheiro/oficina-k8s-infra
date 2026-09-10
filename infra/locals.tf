locals {
  prefix       = "oficina-${var.environment}"
  cluster_name = coalesce(var.cluster_name, "oficina-${var.environment}")
  azs          = slice(data.aws_availability_zones.available.names, 0, 2)
}
