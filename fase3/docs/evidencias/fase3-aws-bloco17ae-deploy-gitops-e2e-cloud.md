# Fase 3 - AWS Academy - BLOCO AWS-17AE - Deploy GitOps e E2E cloud completo

Data: 2026-05-23

## Objetivo

Registrar a validação consolidada do deploy GitOps da Fase 3 no EKS e do fluxo funcional end-to-end cloud, incluindo:

- ArgoCD;
- GitOps;
- microsserviços no EKS;
- RDS PostgreSQL;
- Redis;
- SQS real;
- analytics-service;
- DynamoDB real.

## Contexto

Após a infraestrutura AWS da Fase 3 ter sido criada via Terraform e validada sem drift, os cinco microsserviços foram buildados e publicados no Amazon ECR.

Os manifests GitOps foram atualizados para apontar para as imagens reais do ECR e para consumir:

- ConfigMap com variáveis não sensíveis;
- Kubernetes Secret operacional com valores sensíveis criados fora do Git.

Nenhum segredo foi versionado no repositório.

## GitOps / ArgoCD

O ArgoCD foi instalado no cluster EKS e corrigido para incluir os CRDs principais:

- applications.argoproj.io;
- appprojects.argoproj.io;
- applicationsets.argoproj.io.

O repositório privado GitHub foi conectado ao ArgoCD via SSH deploy key read-only.

A aplicação ArgoCD `togglemaster-dev` foi aplicada e sincronizada com o repositório.

Status final observado:

- Sync Status: Synced;
- Health Status: Healthy;
- Revision: 621563ea05c97afc670d9142fc9b9803d871b3a5.

## Deploy dos microsserviços no EKS

Foram implantados via GitOps os cinco microsserviços:

- auth-service;
- flag-service;
- targeting-service;
- evaluation-service;
- analytics-service.

Status final observado:

- todos os pods `1/1 Running`;
- todos os Deployments com rollout concluído;
- Services ClusterIP criados para os cinco serviços;
- health check HTTP 200 para todos os serviços.

## Correções realizadas durante o deploy

Durante a validação cloud, foram corrigidos problemas reais de runtime:

### DATABASE_URL do auth-service

O `auth-service` falhou inicialmente por erro de parse da `DATABASE_URL`, causado por caracteres especiais na senha do RDS.

Correção aplicada:

- gerar `DATABASE_URL` com URL encoding de usuário/senha;
- atualizar o Kubernetes Secret operacional;
- reiniciar o `auth-service`.

Resultado:

- `auth-service` conectou no PostgreSQL com sucesso.

### Limite de pods durante rollout

O novo pod do `auth-service` ficou em Pending por limite de pods nos nodes:

- `0/2 nodes are available: 2 Too many pods`.

Correção aplicada nos manifests GitOps:

- `maxSurge: 0`;
- `maxUnavailable: 1`.

Resultado:

- rollouts passaram sem exigir pod extra;
- ArgoCD voltou para `Synced / Healthy`.

### Schema do auth-service

O endpoint `POST /admin/keys` retornou erro porque a tabela `api_keys` não existia no RDS cloud.

Correção aplicada:

- criação da tabela `api_keys` no RDS do auth-service, baseada no `db/init.sql` da aplicação.

Resultado:

- API key criada com HTTP 201;
- `/validate` retornou HTTP 200 com `Chave válida`.

### SERVICE_API_KEY do evaluation-service

Após criar a API key real no `auth-service`, o Kubernetes Secret operacional foi atualizado com a `SERVICE_API_KEY` correta.

Resultado:

- `evaluation-service` foi reiniciado;
- novos pods ficaram Ready;
- validações funcionais passaram.

### Schemas do flag-service e targeting-service

Durante o E2E cloud, o `flag-service` retornou erro porque a tabela `flags` não existia.

Correção aplicada:

- criação da tabela `flags` no RDS do flag-service;
- criação da tabela `targeting_rules` no RDS do targeting-service.

Resultado:

- flag criada com sucesso;
- regra targeting criada com sucesso;
- E2E cloud passou.

## Health checks

Foram validados os endpoints `/health` dos cinco serviços:

- auth-service: HTTP 200;
- flag-service: HTTP 200;
- targeting-service: HTTP 200;
- evaluation-service: HTTP 200;
- analytics-service: HTTP 200.

## E2E cloud funcional

Foi executado o script seguro:

- `/tmp/togglemaster_phase3_e2e_cloud.sh`.

O script retornou:

- `SCRIPT_RC=0`.

O fluxo validado incluiu:

1. leitura segura da `SERVICE_API_KEY` a partir do Kubernetes Secret;
2. health check dos serviços usados no E2E;
3. criação da flag `enable-new-dashboard`;
4. listagem da flag;
5. criação da regra targeting `PERCENTAGE` com valor `50`;
6. consulta da regra targeting;
7. avaliação dos usuários de teste.

Resultados das avaliações:

- `user-123`: `result=true`;
- `user-abc`: `result=false`;
- `user-123-sqs`: `result=true`.

O `evaluation-service` registrou envio dos eventos para SQS.

## Validação SQS / analytics-service / DynamoDB

Foi executado o script seguro:

- `/tmp/togglemaster_phase3_validate_analytics_dynamodb.sh`.

O script retornou:

- `SCRIPT_RC=0`.

Validações realizadas:

- credenciais AWS temporárias estavam carregadas;
- identidade AWS via `sts get-caller-identity` validada;
- URL da fila SQS obtida via Terraform output;
- nome da tabela DynamoDB obtido via Terraform output;
- logs do `analytics-service` confirmaram consumo de mensagens;
- logs do `analytics-service` confirmaram gravação no DynamoDB;
- fila SQS ficou sem mensagens pendentes;
- DynamoDB retornou `DDB_COUNT=3`.

Amostra validada no DynamoDB:

- evento para `user-123` com `result=true`;
- evento para `user-abc` com `result=false`;
- evento para `user-123-sqs` com `result=true`;
- `flag_name=enable-new-dashboard`.

## Estado final

Estado final observado:

- ArgoCD `togglemaster-dev`: Synced / Healthy;
- todos os pods ToggleMaster: Running / Ready;
- SQS: sem mensagens pendentes;
- DynamoDB: 3 eventos gravados;
- Git: working tree clean.

## Observações de segurança

Nenhuma credencial sensível foi versionada no Git.

Os valores sensíveis usados em runtime foram mantidos em Kubernetes Secret operacional criado fora do repositório.

Como o AWS Academy usa credenciais temporárias, o Secret operacional deve ser recriado ou atualizado quando uma nova sessão de Lab for iniciada.

## Status

BLOCO AWS-17AE concluído com sucesso.

A Fase 3 possui agora deploy cloud via GitOps e fluxo E2E cloud completo validado.
