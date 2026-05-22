# Fase 2 - BLOCO 15 - Runtime/Compose consolidado

Data: Fri May 22 01:24:47 PM -03 2026

## Objetivo

Consolidar o Docker Compose funcional validado no BLOCO 17, garantindo que a Fase 2 local possa ser reconstruída com os mesmos parâmetros que passaram no E2E.

## Correções consolidadas

- LocalStack fixado em `localstack/localstack:3.8.1`.
- SQS `togglemaster-events` criado de forma idempotente.
- DynamoDB `ToggleMasterAnalytics` criado de forma idempotente.
- `auth-service` com `PORT=8000` e `MASTER_KEY=local-master-key`.
- `flag-service` com `AUTH_SERVICE_URL=http://auth-service:8000`.
- `targeting-service` com `AUTH_SERVICE_URL=http://auth-service:8000`.
- `evaluation-service` com `PORT=8000`.
- `evaluation-service` com `REDIS_URL=redis://redis:6379`.
- `evaluation-service` com `AWS_ENDPOINT_URL=http://localstack:4566`.
- `analytics-service` com `AWS_ENDPOINT_URL=http://localstack:4566`.
- `analytics-service` com `AWS_DYNAMODB_TABLE=ToggleMasterAnalytics`.
- Credenciais fake `test/test` restritas ao LocalStack local.
- `restart: unless-stopped` nos serviços principais.
- `docker compose config` validado.

## Arquivos

- Compose: `/home/wellk/togglemaster-tc/fase2/docker/docker-compose.phase2-exec.yaml`
- Env local: `/home/wellk/togglemaster-tc/fase2/docker/.env.phase2.local`
- Render: `/home/wellk/togglemaster-tc/fase2/logs/fase2-compose-bloco15-rendered.yaml`
- Log: `/home/wellk/togglemaster-tc/fase2/logs/fase2-bloco15-fix-compose-runtime.log`
- Backup: `/home/wellk/togglemaster-tc/fase2/tmp/backups-bloco15-20260522-132447`
