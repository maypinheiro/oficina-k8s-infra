locals {
  monitor_tags = ["project:oficina", "env:${var.environment}", "managed-by:terraform"]
}

resource "datadog_monitor" "http_5xx" {
  name    = "[${upper(var.environment)}] Oficina API - aumento de HTTP 5xx"
  type    = "query alert"
  query   = "sum(last_5m):sum:trace.express.request.errors{env:${var.environment},service:oficina-api}.as_count() > 5"
  message = "A API apresentou mais de 5 erros em 5 minutos. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 5 }
}

resource "datadog_monitor" "latency" {
  name    = "[${upper(var.environment)}] Oficina API - latencia p95 elevada"
  type    = "query alert"
  query   = "avg(last_10m):p95:trace.express.request.duration{env:${var.environment},service:oficina-api} > 2"
  message = "Latencia p95 acima de 2 segundos por 10 minutos. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 2 }
}

resource "datadog_monitor" "api_unavailable" {
  name    = "[${upper(var.environment)}] Oficina API indisponivel"
  type    = "query alert"
  query   = "max(last_5m):sum:kubernetes_state.deployment.replicas_available{env:${var.environment},kube_deployment:oficina-api} < 1"
  message = "Nenhuma replica da API esta disponivel. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 1 }
}

resource "datadog_monitor" "pod_restarts" {
  name    = "[${upper(var.environment)}] Oficina API - pods reiniciando"
  type    = "query alert"
  query   = "change(sum(last_10m),last_10m):sum:kubernetes.containers.restarts{env:${var.environment},kube_deployment:oficina-api} > 2"
  message = "Pods da API reiniciaram repetidamente. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 2 }
}

resource "datadog_monitor" "lambda_errors" {
  name    = "[${upper(var.environment)}] Oficina Auth - falha de Function"
  type    = "query alert"
  query   = "sum(last_5m):sum:aws.lambda.errors{env:${var.environment},service:oficina-auth}.as_count() > 0"
  message = "A Function de autenticacao apresentou falha. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 0 }
}

resource "datadog_monitor" "rds_connections" {
  name    = "[${upper(var.environment)}] Oficina RDS - conexoes elevadas"
  type    = "query alert"
  query   = "avg(last_10m):avg:aws.rds.database_connections{env:${var.environment}} > 70"
  message = "Conexoes do PostgreSQL proximas do limite. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 70 }
}

resource "datadog_monitor" "pod_cpu" {
  name    = "[${upper(var.environment)}] Oficina API - CPU sustentada"
  type    = "query alert"
  query   = "avg(last_15m):avg:kubernetes.cpu.usage.total{env:${var.environment},kube_deployment:oficina-api} > 0.8"
  message = "CPU dos pods elevada por 15 minutos. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 0.8 }
}

resource "datadog_monitor" "pod_memory" {
  name    = "[${upper(var.environment)}] Oficina API - memoria sustentada"
  type    = "query alert"
  query   = "avg(last_15m):avg:kubernetes.memory.usage_pct{env:${var.environment},kube_deployment:oficina-api} > 0.85"
  message = "Memoria dos pods acima de 85%. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 0.85 }
}

resource "datadog_monitor" "os_operation_errors" {
  name    = "[${upper(var.environment)}] Oficina - falha em operacao de OS"
  type    = "query alert"
  query   = "sum(last_5m):sum:oficina.os.operation_errors{env:${var.environment}}.as_count() > 0"
  message = "Falha na abertura ou mudanca de status de OS. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 0 }
}

resource "datadog_monitor" "postgres_errors" {
  count = var.enable_log_monitors ? 1 : 0

  name    = "[${upper(var.environment)}] Oficina - falha de conexao PostgreSQL"
  type    = "log alert"
  query   = "logs(\"service:oficina-api env:${var.environment} PrismaClientInitializationError\").index(\"*\").rollup(\"count\").last(\"5m\") > 0"
  message = "A API registrou falha de conexao PostgreSQL. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 0 }
}
