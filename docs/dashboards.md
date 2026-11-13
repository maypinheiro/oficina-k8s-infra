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
