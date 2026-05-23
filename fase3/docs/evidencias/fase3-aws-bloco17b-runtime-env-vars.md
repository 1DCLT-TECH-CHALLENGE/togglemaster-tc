# Fase 3 - AWS Academy - BLOCO AWS-17B - Mapeamento limpo de variáveis runtime

Data: 2026-05-22

## Objetivo

Registrar o mapeamento limpo das variáveis de runtime exigidas pelo código real dos cinco microsserviços.

A inspeção foi feita diretamente nos arquivos principais dos serviços, evitando ruído de README, backups e pycache.

## Variáveis por serviço

### auth-service

Arquivo analisado:

- fase2/src/services/auth-service/main.go

Variáveis identificadas:

- PORT
- DATABASE_URL
- MASTER_KEY

Observação:

DATABASE_URL e MASTER_KEY são obrigatórias para o serviço iniciar.

### flag-service

Arquivo analisado:

- fase2/src/services/flag-service/app.py

Variáveis identificadas:

- DATABASE_URL
- AUTH_SERVICE_URL
- PORT

Observação:

DATABASE_URL e AUTH_SERVICE_URL são obrigatórias.

### targeting-service

Arquivo analisado:

- fase2/src/services/targeting-service/app.py

Variáveis identificadas:

- DATABASE_URL
- AUTH_SERVICE_URL
- PORT

Observação:

DATABASE_URL e AUTH_SERVICE_URL são obrigatórias.

### evaluation-service

Arquivos analisados:

- fase2/src/services/evaluation-service/main.go
- fase2/src/services/evaluation-service/evaluator.go

Variáveis identificadas:

- PORT
- REDIS_URL
- FLAG_SERVICE_URL
- TARGETING_SERVICE_URL
- AWS_SQS_URL
- AWS_REGION
- AWS_ENDPOINT_URL
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- SERVICE_API_KEY

Observação:

REDIS_URL, FLAG_SERVICE_URL e TARGETING_SERVICE_URL são obrigatórias.

AWS_SQS_URL é opcional no código, mas necessária para envio real de eventos.

SERVICE_API_KEY é necessária para chamar flag-service e targeting-service com Authorization Bearer.

AWS_ENDPOINT_URL é opcional e usado no cenário LocalStack.

### analytics-service

Arquivo analisado:

- fase2/src/services/analytics-service/app.py

Variáveis identificadas:

- AWS_REGION
- AWS_SQS_URL
- AWS_DYNAMODB_TABLE
- AWS_ENDPOINT_URL
- PORT

Observação:

AWS_REGION, AWS_SQS_URL e AWS_DYNAMODB_TABLE são obrigatórias.

AWS_ENDPOINT_URL é opcional e usado no cenário LocalStack.

## ConfigMap atual

O ConfigMap GitOps atual contém apenas:

- AUTH_SERVICE_URL
- FLAG_SERVICE_URL
- TARGETING_SERVICE_URL
- REDIS_PORT
- AWS_REGION

## Lacunas antes do deploy

Ainda faltam mecanismos seguros para entregar:

- DATABASE_URL do auth-service;
- DATABASE_URL do flag-service;
- DATABASE_URL do targeting-service;
- MASTER_KEY do auth-service;
- SERVICE_API_KEY do evaluation-service;
- REDIS_URL do evaluation-service;
- AWS_SQS_URL;
- AWS_DYNAMODB_TABLE.

## Decisão

Não aplicar os manifests no cluster ainda.

Antes do deploy, será necessário separar variáveis não sensíveis em ConfigMap e variáveis sensíveis em mecanismo seguro de secrets.

## Status

BLOCO AWS-17B concluído com sucesso.
