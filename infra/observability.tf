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
  query   = "avg(last_10m):p95:oficina.http.request.duration_ms{env:${var.environment},service:oficina-api} > 2000"
  message = "Latencia p95 acima de 2 segundos por 10 minutos. ${var.alert_notification}"
  tags    = local.monitor_tags
  monitor_thresholds { critical = 2000 }
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

resource "datadog_monitor" "saga_failed" {
  name    = "[${upper(var.environment)}] Oficina Saga - falha transacional"
  type    = "query alert"
  query   = "sum(last_5m):sum:oficina.saga.failed{env:${var.environment}}.as_count() > 0"
  message = "A Saga registrou falha no inicio ou no processamento de um evento. Correlacione logs por sagaId/correlationId e inspecione as DLQs. ${var.alert_notification}"
  tags    = concat(local.monitor_tags, ["scope:fase4", "pattern:saga"])
  monitor_thresholds { critical = 0 }
}

resource "datadog_monitor" "saga_consumer_failed" {
  name    = "[${upper(var.environment)}] Oficina Saga - falha em consumidor"
  type    = "query alert"
  query   = "sum(last_5m):sum:oficina.saga.messages.failed{env:${var.environment}}.as_count() > 0"
  message = "Billing ou Execution falhou ao consumir um comando da Saga. Verifique a fila, a DLQ e os logs pelo correlationId. ${var.alert_notification}"
  tags    = concat(local.monitor_tags, ["scope:fase4", "pattern:saga"])
  monitor_thresholds { critical = 0 }
}

resource "datadog_monitor" "saga_message_latency" {
  name    = "[${upper(var.environment)}] Oficina Saga - latencia p95 de mensagem elevada"
  type    = "query alert"
  query   = "avg(last_10m):p95:oficina.saga.message.duration_ms{env:${var.environment}} > 2000"
  message = "O processamento p95 de mensagens da Saga permaneceu acima de 2 segundos. Verifique consumidores, filas e dependencias. ${var.alert_notification}"
  tags    = concat(local.monitor_tags, ["scope:fase4", "pattern:saga"])
  monitor_thresholds { critical = 2000 }
}

resource "datadog_monitor" "microservices_unavailable" {
  name    = "[${upper(var.environment)}] Oficina - microsservico indisponivel"
  type    = "query alert"
  query   = "min(last_5m):sum:kubernetes_state.deployment.replicas_available{env:${var.environment},kube_deployment IN (oficina-api,oficina-billing-service,oficina-execution-service)} by {kube_deployment} < 1"
  message = "Um dos microsservicos da Saga esta sem replicas disponiveis. Identifique o kube_deployment no alerta e valide rollout, probes e eventos. ${var.alert_notification}"
  tags    = concat(local.monitor_tags, ["scope:fase4", "pattern:saga"])
  monitor_thresholds { critical = 1 }
}

resource "datadog_monitor" "saga_dlq_messages" {
  name    = "[${upper(var.environment)}] Oficina Saga - mensagens em DLQ"
  type    = "query alert"
  query   = "max(last_5m):max:aws.sqs.approximate_number_of_messages_visible{env:${var.environment},queuename:*dlq*} by {queuename} > 0"
  message = "Uma DLQ da Saga possui mensagens. Preserve a mensagem para diagnostico, correlacione sagaId/correlationId e execute replay somente depois de corrigir a causa. ${var.alert_notification}"
  tags    = concat(local.monitor_tags, ["scope:fase4", "pattern:saga"])
  monitor_thresholds { critical = 0 }
}

resource "datadog_monitor" "saga_telemetry_missing" {
  name                = "[${upper(var.environment)}] Oficina Saga - telemetria ausente"
  type                = "query alert"
  query               = "sum(last_10m):sum:oficina.saga.messages.processed{env:${var.environment}}.as_count() < 1"
  message             = "Nenhuma mensagem processada foi observada por 10 minutos durante a janela operacional da demonstracao. Valide consumidores, Agent e DogStatsD. ${var.alert_notification}"
  tags                = concat(local.monitor_tags, ["scope:fase4", "pattern:saga"])
  notify_no_data      = true
  no_data_timeframe   = 10
  require_full_window = false
  monitor_thresholds { critical = 1 }
}

resource "datadog_monitor" "saga_compensation_baseline" {
  name    = "[${upper(var.environment)}] Oficina Saga - compensacoes acima do baseline"
  type    = "query alert"
  query   = "sum(last_15m):sum:oficina.saga.compensated{env:${var.environment}}.as_count() > 2"
  message = "Mais de duas Sagas foram compensadas em 15 minutos, acima do baseline academico. Investigue a causa antes de reprocessar. ${var.alert_notification}"
  tags    = concat(local.monitor_tags, ["scope:fase4", "pattern:saga"])
  monitor_thresholds { critical = 2 }
}
