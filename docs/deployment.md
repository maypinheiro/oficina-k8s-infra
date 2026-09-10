# Deploy no Amazon EKS

## Ordem

1. aplicar `infra/` com credenciais temporarias do Learner Lab;
2. configurar o `kubectl` com o output `configure_kubectl_command`;
3. instalar AWS Load Balancer Controller, External Secrets Operator e Cluster Autoscaler;
   aplicar `observability/datadog-secret.yaml` e instalar o chart `datadog/datadog`
   com `observability/datadog-values.yaml`;
4. substituir `oficina-env`, `ENVIRONMENT`, `IMAGE_TAG` e `CORS_ORIGIN` nos manifests;
5. aplicar namespace, secret store, configuracao e external secrets;
6. executar `prisma-job.yaml` e aguardar conclusao;
7. aplicar API, PDB e HPA e aguardar o rollout;
8. fornecer o ARN do listener do NLB interno ao Terraform do API Gateway.

`postgres.yaml` e `metrics-server.yaml` sao legados locais e nao entram nesse fluxo.
O metrics-server cloud e instalado como add-on do EKS.

O External Secrets materializa somente o Secret consumido pelos pods. No Learner
Lab, o acesso inicial usa a role fornecida; em conta corporativa, usar IRSA/Pod
Identity com acesso somente aos segredos declarados.

O Cluster Autoscaler deve usar autodiscovery pelo nome do cluster. O node group
ja recebe as tags de descoberta e os limites `min/desired/max` definidos por
ambiente. A permissao de Auto Scaling depende da role liberada pelo Learner Lab.

A imagem no ECR possui tags imutaveis. A pipeline substitui `IMAGE_TAG` pelo SHA
do commit, executa a migration antes do rollout e nunca utiliza `latest`.

As API/App keys do Terraform entram somente por `TF_VAR_datadog_api_key` e
`TF_VAR_datadog_app_key`. A integração AWS exige uma role cross-account; no
Learner Lab ela será habilitada somente se essa role for permitida. Sem ela,
EKS/APM/logs funcionam, mas métricas CloudWatch de Gateway, Lambda e RDS não
chegam ao Datadog.
