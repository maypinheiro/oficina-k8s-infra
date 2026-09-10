# Dashboards Datadog

O monitor de erro PostgreSQL baseado em logs usa `enable_log_monitors=true` e
deve ser habilitado depois da primeira ingestão no Log Management. Os monitores
baseados em métricas e os dashboards podem ser criados desde o primeiro deploy.

O Terraform cria uma visão por ambiente para cada público:

1. **Operação da API**: latência p95 por rota, throughput, HTTP 5xx e uptime;
2. **Kubernetes**: CPU, memória, réplicas desejadas/disponíveis, restarts e HPA;
3. **Ordens de serviço**: volume diário, duração média em diagnóstico, execução e
   até finalização, erros de OS e falhas de integração/Function.

Os links são expostos pelo output `datadog_dashboard_urls`. Após o deploy, execute
`scripts/demo-observability.ps1` do repositório da API com a URL do Gateway e um
JWT válido. O script gera tráfego e solicita o cálculo das métricas de negócio,
evitando gráficos vazios durante a demonstração.

As métricas de duração consideram os intervalos:

- diagnóstico: `EM_DIAGNOSTICO` até `AGUARDANDO_APROVACAO`;
- execução: `EM_EXECUCAO` até `FINALIZADA`;
- finalização: criação da OS até `FINALIZADA`.
