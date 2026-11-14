# Dashboards Datadog

O monitor de erro PostgreSQL baseado em logs usa `enable_log_monitors=true` e
deve ser habilitado depois da primeira ingestão no Log Management. Os monitores
baseados em métricas e os dashboards podem ser criados desde o primeiro deploy.

O Terraform cria uma visão por ambiente para cada público:

1. **Operação da API**: latência p95 por rota, throughput, HTTP 5xx e uptime;
2. **Kubernetes**: CPU, memória, réplicas desejadas/disponíveis, restarts e HPA;
3. **Ordens de serviço**: volume diário, duração média em diagnóstico, execução e
   até finalização, erros de OS e falhas de integração/Function;
4. **Saga distribuída**: sagas iniciadas/concluídas/compensadas, transições,
   mensagens processadas/duplicadas/com falha, latências p50/p95 e saúde dos três
   microsserviços.

Os links são expostos pelo output `datadog_dashboard_urls`. Após o deploy, execute
`scripts/demo-observability.ps1` do repositório da API com a URL do Gateway e um
JWT válido. O script gera tráfego e solicita o cálculo das métricas de negócio,
evitando gráficos vazios durante a demonstração.

## Evidência da organização vigente

O apply HML foi concluído pela
[execução 43528997327](https://github.com/maypinheiro/oficina-k8s-infra/actions/runs/43528997327)
e publicou os seguintes recursos:

| Visão | Dashboard |
|---|---|
| Operação da API | <https://app.datadoghq.com/dashboard/tvf-tig-7k5> |
| Kubernetes/HPA | <https://app.datadoghq.com/dashboard/s9s-5yb-abz> |
| Ordens de Serviço | <https://app.datadoghq.com/dashboard/jk8-5k2-e5b> |
| Saga distribuída | <https://app.datadoghq.com/dashboard/qzn-ptj-zm5> |

Em 13/11/2026, a conferência visual do dashboard da Saga mostrou métricas de
conclusão e compensação, transições por evento/etapa, consumo por Billing e
Execution, réplicas Kubernetes e logs dos três microsserviços. A busca dos dois
`correlationId` finais pela API do Datadog retornou 25 registros distribuídos
entre OS, Billing e Execution.

Na Fase 4, gere também um fluxo feliz e um fluxo com compensação. Os serviços
publicam métricas `oficina.saga.*` com tags `env`, `service`, `event` e `step`;
os logs JSON carregam `correlationId`, `sagaId`, `eventId` e `ordemServicoId`.
Assim, a mesma transação pode ser seguida do Gateway até Billing e Execution.

Alertas versionados cobrem falha da Saga, falha de consumidor, latência p95 de
mensagens e ausência de réplicas dos microsserviços. Os IDs dos recursos não são
fixados no pipeline: ao trocar de organização Datadog, as chaves do Environment
selecionam o destino e o Terraform cria os recursos nessa organização.

As métricas de duração consideram os intervalos:

- diagnóstico: `EM_DIAGNOSTICO` até `AGUARDANDO_APROVACAO`;
- execução: `EM_EXECUCAO` até `FINALIZADA`;
- finalização: criação da OS até `FINALIZADA`.
