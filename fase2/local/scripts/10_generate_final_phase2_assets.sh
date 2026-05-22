#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"

MATRIX="$BASE/docs/evidencias/fase2-runtime-matrix-consolidada.md"

DOCKER_DIR="$BASE/docker"
DOCS_DIR="$BASE/docs/evidencias"
LOG_DIR="$BASE/logs"

OUTPUT_COMPOSE="$DOCKER_DIR/docker-compose.phase2-final.yaml"
OUTPUT_ENV="$DOCKER_DIR/.env.example"

LOG="$LOG_DIR/fase2-bloco10-generate-assets.log"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 10 - GERAÇÃO DOS ASSETS FINAIS"
echo "============================================================"

if [ ! -f "$MATRIX" ]; then
  echo "ERRO: matriz consolidada não encontrada:"
  echo "$MATRIX"
  exit 1
fi

mkdir -p "$DOCKER_DIR"
mkdir -p "$DOCS_DIR"

echo
echo "[1/4] Gerando .env.example"

cat > "$OUTPUT_ENV" <<'ENVEOF'
# ============================================================
# ToggleMaster - Phase 2
# Ambiente local
# ============================================================

SERVICE_API_KEY=change-me

AWS_REGION=us-east-1
AWS_ENDPOINT_URL=http://localstack:4566
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test

AWS_SQS_URL=http://localstack:4566/000000000000/togglemaster-events

POSTGRES_USER=togglemaster
POSTGRES_PASSWORD=togglemaster
POSTGRES_DB=togglemaster

REDIS_HOST=redis
REDIS_PORT=6379
ENVEOF

echo
echo "[2/4] Gerando compose consolidado"

cat > "$OUTPUT_COMPOSE" <<'COMPOSEEOF'
version: "3.9"

services:

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  localstack:
    image: localstack/localstack:3.8.1
    environment:
      - SERVICES=sqs,dynamodb
      - DEBUG=0
    ports:
      - "4566:4566"

  auth-service:
    build:
      context: ../src/services/auth-service
    ports:
      - "8001:8001"

  flag-service:
    build:
      context: ../src/services/flag-service
    ports:
      - "8002:8002"

  targeting-service:
    build:
      context: ../src/services/targeting-service
    ports:
      - "8003:8003"

  evaluation-service:
    build:
      context: ../src/services/evaluation-service
    environment:
      - AWS_REGION=us-east-1
      - AWS_ENDPOINT_URL=http://localstack:4566
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
    ports:
      - "8004:8004"

  analytics-service:
    build:
      context: ../src/services/analytics-service
    environment:
      - AWS_REGION=us-east-1
      - AWS_ENDPOINT_URL=http://localstack:4566
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
    ports:
      - "8005:8005"
COMPOSEEOF

echo
echo "[3/4] Gerando evidência"

cat > "$DOCS_DIR/fase2-assets-finais.md" <<EOF2
# Fase 2 - Assets Finais Gerados

Data: $(date)

## Arquivos gerados

- docker/docker-compose.phase2-final.yaml
- docker/.env.example

## Objetivo

Consolidar os assets locais finais da Fase 2 com base
na matriz operacional validada anteriormente.

## Observações

- Nenhum recurso AWS real foi criado
- LocalStack permanece como ambiente local
- Compose ainda pode receber refinamentos incrementais
- A Fase 3 continuará responsável pela infraestrutura cloud real via Terraform
EOF2

echo
echo "[4/4] Resumo"

echo "Compose:"
echo "$OUTPUT_COMPOSE"

echo
echo ".env:"
echo "$OUTPUT_ENV"

echo
echo "============================================================"
echo "BLOCO 10 FINALIZADO"
echo "============================================================"
