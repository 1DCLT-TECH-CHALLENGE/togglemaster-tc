#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"

LOG="$BASE/logs/fase2-bloco16-stabilize-runtime.log"
EVID="$BASE/docs/evidencias/fase2-bloco16-estabilizacao-runtime.md"

COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias"

exec > >(tee "$LOG") 2>&1

compose() {
  docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" "$@"
}

wait_http() {
  local name="$1"
  local url="$2"
  local max="${3:-30}"

  echo
  echo "Aguardando $name em $url"

  for i in $(seq 1 "$max")
  do
    if curl -fsS --max-time 5 "$url" >/dev/null 2>&1; then
      echo "OK: $name disponível."
      return 0
    fi

    echo "Tentativa $i/$max ainda sem resposta para $name."
    sleep 3
  done

  echo "ERRO: timeout aguardando $name em $url"
  return 1
}

health_service() {
  local port="$1"
  local name="$2"

  echo
  echo "### $name / porta $port ###"

  curl -fsS --max-time 8 "http://localhost:$port/health" \
    | tee "$BASE/logs/fase2-bloco16-health-$name.json"

  echo
  echo "OK: $name health"
}

echo "============================================================"
echo "FASE 2 - BLOCO 16 - ESTABILIZAÇÃO DO RUNTIME CONSOLIDADA"
echo "============================================================"
echo "Data: $(date)"
echo

###############################################################################
# PRECHECK
###############################################################################

echo
echo "[1/9] Validando arquivos obrigatórios"

for f in "$COMPOSE_FILE" "$ENV_FILE"
do
  if [ ! -f "$f" ]; then
    echo "ERRO: arquivo obrigatório não encontrado: $f"
    exit 1
  fi
  echo "OK: $f"
done

cd "$DOCKER_DIR"

###############################################################################
# STATUS INICIAL
###############################################################################

echo
echo "[2/9] Status inicial"

compose ps || true

###############################################################################
# LOCALSTACK
###############################################################################

echo
echo "[3/9] Subindo LocalStack"

compose up -d localstack

wait_http "LocalStack health" "http://localhost:4566/_localstack/health" 40

###############################################################################
# SQS
###############################################################################

echo
echo "[4/9] Garantindo fila SQS LocalStack"

compose exec -T localstack awslocal sqs create-queue \
  --queue-name togglemaster-events || true

compose exec -T localstack awslocal sqs list-queues \
  | tee "$BASE/logs/fase2-bloco16-sqs-list-queues.json"

if ! grep -q "togglemaster-events" "$BASE/logs/fase2-bloco16-sqs-list-queues.json"; then
  echo "ERRO: fila togglemaster-events não encontrada no LocalStack."
  exit 1
fi

echo "OK: fila SQS togglemaster-events disponível."

###############################################################################
# DYNAMODB
###############################################################################

echo
echo "[5/9] Garantindo tabela DynamoDB LocalStack"

compose exec -T localstack awslocal dynamodb create-table \
  --table-name ToggleMasterAnalytics \
  --attribute-definitions AttributeName=event_id,AttributeType=S \
  --key-schema AttributeName=event_id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST || true

compose exec -T localstack awslocal dynamodb list-tables \
  | tee "$BASE/logs/fase2-bloco16-dynamodb-list-tables.json"

if ! grep -q "ToggleMasterAnalytics" "$BASE/logs/fase2-bloco16-dynamodb-list-tables.json"; then
  echo "ERRO: tabela ToggleMasterAnalytics não encontrada no LocalStack."
  exit 1
fi

echo "OK: tabela DynamoDB ToggleMasterAnalytics disponível."

###############################################################################
# BUILD
###############################################################################

echo
echo "[6/9] Buildando aplicações"

compose build \
  auth-service \
  flag-service \
  targeting-service \
  evaluation-service \
  analytics-service

###############################################################################
# SUBIDA
###############################################################################

echo
echo "[7/9] Subindo stack completa"

compose up -d --force-recreate \
  auth-service \
  flag-service \
  targeting-service \
  evaluation-service \
  analytics-service \
  localstack-init

echo
echo "Aguardando serviços estabilizarem..."
sleep 20

###############################################################################
# HEALTH
###############################################################################

echo
echo "[8/9] Health checks obrigatórios"

health_service 8001 auth-service
health_service 8002 flag-service
health_service 8003 targeting-service
health_service 8004 evaluation-service
health_service 8005 analytics-service

###############################################################################
# EVIDENCE
###############################################################################

echo
echo "[9/9] Gerando evidência"

{
  echo "# Fase 2 - BLOCO 16 - Estabilização Runtime"
  echo
  echo "Data: $(date)"
  echo
  echo "## Resultado"
  echo
  echo "Runtime da Fase 2 estabilizado com sucesso."
  echo
  echo "## Containers"
  echo
  compose ps
  echo
  echo "## Health checks validados"
  echo
  echo "- 8001 auth-service: OK"
  echo "- 8002 flag-service: OK"
  echo "- 8003 targeting-service: OK"
  echo "- 8004 evaluation-service: OK"
  echo "- 8005 analytics-service: OK"
  echo
  echo "## Recursos LocalStack"
  echo
  echo "- fila SQS: \`togglemaster-events\`"
  echo "- tabela DynamoDB: \`ToggleMasterAnalytics\`"
  echo
  echo "## Arquivos"
  echo
  echo "- Log: \`$LOG\`"
  echo "- SQS list queues: \`$BASE/logs/fase2-bloco16-sqs-list-queues.json\`"
  echo "- DynamoDB list tables: \`$BASE/logs/fase2-bloco16-dynamodb-list-tables.json\`"
} > "$EVID"

echo
echo "============================================================"
echo "BLOCO 16 FINALIZADO COM SUCESSO"
echo "LOG: $LOG"
echo "EVIDÊNCIA: $EVID"
echo "============================================================"
