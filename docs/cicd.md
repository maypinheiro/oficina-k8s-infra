# CI/CD cloud

Cada repositório executa CI em pull requests. O CD é automático após CI bem-sucedido em `homolog` e `main`, com destino `hml` e `prod`, respectivamente. O disparo manual permanece disponível para contingência e produção requer aprovação do GitHub Environment.
O deploy de `prod` deve usar required reviewers no GitHub Environment.

## Ordem do primeiro provisionamento

1. criar previamente o bucket S3 e a tabela DynamoDB para state/lock;
2. executar `oficina-k8s-infra` para criar VPC, EKS e ECR;
3. cadastrar seus outputs nos environments dos demais repositórios;
4. executar `oficina-database-infra`;
5. cadastrar o ARN do segredo do banco;
6. instalar os operadores descritos em `deployment.md` e obter o listener do NLB;
7. executar `oficina-auth-function`;
8. executar `oficina-api`.

## Secrets comuns dos GitHub Environments

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`;
- `TF_STATE_BUCKET`, `TF_STATE_LOCK_TABLE`;
- chaves Datadog somente nos repositórios que as consomem.

As credenciais do Learner Lab expiram e devem ser renovadas antes de cada deploy.
Nunca copiar secrets para arquivos versionados ou outputs de workflow.

Os workflows usam concorrência por componente/ambiente, state remoto com lock,
imagem identificada pelo SHA, migrations antes do rollout, smoke tests e outputs
como artefatos de evidência.
