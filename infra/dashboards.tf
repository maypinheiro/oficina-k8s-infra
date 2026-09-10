locals {
  dashboard_variables = { environment = var.environment, environment_upper = upper(var.environment) }
}

resource "datadog_dashboard_json" "api_operations" {
  dashboard = templatefile("${path.module}/dashboards/api.json.tftpl", local.dashboard_variables)
}

resource "datadog_dashboard_json" "kubernetes" {
  dashboard = templatefile("${path.module}/dashboards/kubernetes.json.tftpl", local.dashboard_variables)
}

resource "datadog_dashboard_json" "business" {
  dashboard = templatefile("${path.module}/dashboards/business.json.tftpl", local.dashboard_variables)
}

output "datadog_dashboard_urls" {
  value = {
    api        = "https://app.datadoghq.com/dashboard/${datadog_dashboard_json.api_operations.id}"
    kubernetes = "https://app.datadoghq.com/dashboard/${datadog_dashboard_json.kubernetes.id}"
    business   = "https://app.datadoghq.com/dashboard/${datadog_dashboard_json.business.id}"
  }
}
