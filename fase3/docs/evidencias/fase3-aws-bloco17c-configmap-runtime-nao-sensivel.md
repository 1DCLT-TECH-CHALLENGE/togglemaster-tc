# Fase 3 - AWS Academy - BLOCO AWS-17C - ConfigMap com runtime não sensível

Data: 2026-05-22

## Objetivo

Registrar a atualização do ConfigMap GitOps com variáveis de runtime não sensíveis necessárias para os microsserviços.

## Contexto

Após o mapeamento limpo das variáveis runtime no BLOCO AWS-17B, foi identificado que parte das variáveis pode ser entregue via ConfigMap, pois não contém segredo.

As variáveis sensíveis continuam fora do ConfigMap.

## Variáveis adicionadas/mantidas no ConfigMap

O ConfigMap `togglemaster-runtime-config` passou a conter:

- PORT
- AUTH_SERVICE_URL
- FLAG_SERVICE_URL
- TARGETING_SERVICE_URL
- REDIS_PORT
- REDIS_URL
- AWS_REGION
- AWS_SQS_URL
- AWS_DYNAMODB_TABLE

## Recursos referenciados

Foram usados outputs Terraform para preencher:

- endpoint Redis;
- URL da fila SQS;
- nome da tabela DynamoDB.

## Segurança

Foi validado que o ConfigMap não contém:

- DATABASE_URL;
- MASTER_KEY;
- SERVICE_API_KEY;
- AWS_ACCESS_KEY;
- AWS_SECRET;
- password;
- token;
- secret.

## Validação Kustomize

O overlay dev foi renderizado com sucesso após a alteração.

O render confirmou:

- ConfigMap com as variáveis não sensíveis;
- Deployments ainda apontando para imagens ECR reais com tag c0f03bb;
- envFrom referenciando o ConfigMap.

## Pendências antes do deploy

Ainda falta implementar solução segura para:

- DATABASE_URL do auth-service;
- DATABASE_URL do flag-service;
- DATABASE_URL do targeting-service;
- MASTER_KEY do auth-service;
- SERVICE_API_KEY do evaluation-service.

## Decisão

Ainda não aplicar manifests no cluster.

O próximo passo deve tratar a estratégia segura de secrets.

## Status

BLOCO AWS-17C concluído com sucesso.
