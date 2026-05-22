#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"

LOG="$BASE/logs/fase2-bloco15-fix-compose-runtime.log"
EVID="$BASE/docs/evidencias/fase2-bloco15-runtime-fixes.md"
BACKUP_DIR="$BASE/tmp/backups-bloco15-$(date +%Y%m%d-%H%M%S)"

COMPOSE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

mkdir -p "$DOCKER_DIR" "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 15 - FIX RUNTIME/COMPOSE CONSOLIDADO"
echo "============================================================"
echo "Data: $(date)"
echo

if [ -f "$COMPOSE" ]; then
  cp -a "$COMPOSE" "$BACKUP_DIR/docker-compose.phase2-exec.yaml.bak"
fi

if [ -f "$ENV_FILE" ]; then
  cp -a "$ENV_FILE" "$BACKUP_DIR/.env.phase2.local.bak"
fi

###############################################################################
# ENV FILE
###############################################################################

cat > "$ENV_FILE" <<'ENVEOF'
SERVICE_API_KEY=local-dev-api-key

AWS_REGION=us-east-1
AWS_ENDPOINT_URL=http://localstack:4566
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_SQS_URL=http://localstack:4566/000000000000/togglemaster-events
AWS_DYNAMODB_TABLE=ToggleMasterAnalytics
ENVEOF

###############################################################################
# COMPOSE
###############################################################################

cat > "$COMPOSE" <<'COMPOSEEOF'
services:

  postgres-auth:
    image: postgres:13
    restart: unless-stopped
    environment:
      POSTGRES_DB: auth_db
      POSTGRES_USER: auth_user
      POSTGRES_PASSWORD: auth_pass
    ports:
      - "5433:5432"
    volumes:
      - ../src/services/auth-service/db/init.sql:/docker-entrypoint-initdb.d/init.sql

  postgres-flags:
    image: postgres:13
    restart: unless-stopped
    environment:
      POSTGRES_DB: flags_db
      POSTGRES_USER: flags_user
      POSTGRES_PASSWORD: flags_pass
    ports:
      - "5434:5432"
    volumes:
      - ../src/services/flag-service/db/init.sql:/docker-entrypoint-initdb.d/init.sql

  postgres-targeting:
    image: postgres:13
    restart: unless-stopped
    environment:
      POSTGRES_DB: targeting_db
      POSTGRES_USER: targeting_user
      POSTGRES_PASSWORD: targeting_pass
    ports:
      - "5435:5432"
    volumes:
      - ../src/services/targeting-service/db/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"

  localstack:
    image: localstack/localstack:3.8.1
    restart: unless-stopped
    environment:
      SERVICES: sqs,dynamodb
      DEBUG: "0"
      AWS_DEFAULT_REGION: us-east-1
    ports:
      - "4566:4566"
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:4566/_localstack/health"]
      interval: 10s
      timeout: 5s
      retries: 12

  localstack-init:
    image: amazon/aws-cli:2.15.7
    depends_on:
      localstack:
        condition: service_healthy
    entrypoint: >
      /bin/sh -c "
      aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name togglemaster-events || true;
      aws --endpoint-url=http://localstack:4566 dynamodb create-table
      --table-name ToggleMasterAnalytics
      --attribute-definitions AttributeName=event_id,AttributeType=S
      --key-schema AttributeName=event_id,KeyType=HASH
      --billing-mode PAY_PER_REQUEST || true;
      exit 0;
      "
    environment:
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
      AWS_REGION: us-east-1

  auth-service:
    build:
      context: ../src/services/auth-service
    restart: unless-stopped
    environment:
      DATABASE_URL: postgres://auth_user:auth_pass@postgres-auth:5432/auth_db?sslmode=disable
      MASTER_KEY: local-master-key
      PORT: "8000"
    ports:
      - "8001:8000"
    depends_on:
      - postgres-auth

  flag-service:
    build:
      context: ../src/services/flag-service
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://flags_user:flags_pass@postgres-flags:5432/flags_db
      AUTH_SERVICE_URL: http://auth-service:8000
      SERVICE_API_KEY: local-dev-api-key
    ports:
      - "8002:8000"
    depends_on:
      - postgres-flags
      - auth-service

  targeting-service:
    build:
      context: ../src/services/targeting-service
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://targeting_user:targeting_pass@postgres-targeting:5432/targeting_db
      AUTH_SERVICE_URL: http://auth-service:8000
      SERVICE_API_KEY: local-dev-api-key
    ports:
      - "8003:8000"
    depends_on:
      - postgres-targeting
      - auth-service

  evaluation-service:
    build:
      context: ../src/services/evaluation-service
    restart: unless-stopped
    environment:
      PORT: "8000"
      SERVICE_API_KEY: local-dev-api-key
      FLAG_SERVICE_URL: http://flag-service:8000
      TARGETING_SERVICE_URL: http://targeting-service:8000
      REDIS_URL: redis://redis:6379
      REDIS_ADDR: redis:6379
      REDIS_HOST: redis
      REDIS_PORT: "6379"
      AWS_REGION: us-east-1
      AWS_ENDPOINT_URL: http://localstack:4566
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
    ports:
      - "8004:8000"
    depends_on:
      - redis
      - localstack
      - localstack-init
      - flag-service
      - targeting-service

  analytics-service:
    build:
      context: ../src/services/analytics-service
    restart: unless-stopped
    environment:
      AWS_REGION: us-east-1
      AWS_ENDPOINT_URL: http://localstack:4566
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
      AWS_DYNAMODB_TABLE: ToggleMasterAnalytics
    ports:
      - "8005:8000"
    depends_on:
      - localstack
      - localstack-init
COMPOSEEOF

###############################################################################
# VALIDATE
###############################################################################

cd "$DOCKER_DIR"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE" config > "$BASE/logs/fase2-compose-bloco15-rendered.yaml"

grep -nE 'auth-service:|flag-service:|targeting-service:|evaluation-service:|analytics-service:|PORT:|AUTH_SERVICE_URL|SERVICE_API_KEY|REDIS_URL|AWS_ENDPOINT_URL|AWS_SQS_URL|AWS_DYNAMODB_TABLE|DATABASE_URL|MASTER_KEY' \
  "$BASE/logs/fase2-compose-bloco15-rendered.yaml" || true

###############################################################################
# EVIDENCE
###############################################################################

cat > "$EVID" <<EOF2
# Fase 2 - BLOCO 15 - Runtime/Compose consolidado

Data: $(date)

## Objetivo

Consolidar o Docker Compose funcional validado no BLOCO 17, garantindo que a Fase 2 local possa ser reconstruída com os mesmos parâmetros que passaram no E2E.

## Correções consolidadas

- LocalStack fixado em \`localstack/localstack:3.8.1\`.
- SQS \`togglemaster-events\` criado de forma idempotente.
- DynamoDB \`ToggleMasterAnalytics\` criado de forma idempotente.
- \`auth-service\` com \`PORT=8000\` e \`MASTER_KEY=local-master-key\`.
- \`flag-service\` com \`AUTH_SERVICE_URL=http://auth-service:8000\`.
- \`targeting-service\` com \`AUTH_SERVICE_URL=http://auth-service:8000\`.
- \`evaluation-service\` com \`PORT=8000\`.
- \`evaluation-service\` com \`REDIS_URL=redis://redis:6379\`.
- \`evaluation-service\` com \`AWS_ENDPOINT_URL=http://localstack:4566\`.
- \`analytics-service\` com \`AWS_ENDPOINT_URL=http://localstack:4566\`.
- \`analytics-service\` com \`AWS_DYNAMODB_TABLE=ToggleMasterAnalytics\`.
- Credenciais fake \`test/test\` restritas ao LocalStack local.
- \`restart: unless-stopped\` nos serviços principais.
- \`docker compose config\` validado.

## Arquivos

- Compose: \`$COMPOSE\`
- Env local: \`$ENV_FILE\`
- Render: \`$BASE/logs/fase2-compose-bloco15-rendered.yaml\`
- Log: \`$LOG\`
- Backup: \`$BACKUP_DIR\`
EOF2

echo
echo "============================================================"
echo "BLOCO 15 CONSOLIDADO FINALIZADO"
echo "LOG: $LOG"
echo "EVIDÊNCIA: $EVID"
echo "BACKUP: $BACKUP_DIR"
echo "============================================================"
