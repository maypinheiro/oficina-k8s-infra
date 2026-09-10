# Deploy no Amazon EKS

## Ordem

1. aplicar `infra/` com credenciais temporarias do Learner Lab;
2. configurar o `kubectl` com o output `configure_kubectl_command`;
3. instalar AWS Load Balancer Controller, External Secrets Operator e Cluster Autoscaler;
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
