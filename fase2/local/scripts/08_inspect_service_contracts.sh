#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
UPSTREAM="$BASE/repos/upstream"
LOG="$BASE/logs/fase2-bloco8-service-contracts.log"
EVIDENCE="$BASE/docs/evidencias/fase2-bloco8-service-contracts.md"

mkdir -p "$BASE/logs"
mkdir -p "$BASE/docs/evidencias"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 8 - INSPEÇÃO DOS CONTRATOS DOS SERVIÇOS"
echo "============================================================"

SERVICES=(
  auth-service
  flag-service
  targeting-service
  evaluation-service
  analytics-service
)

{
echo "# FASE 2 - BLOCO 8 - CONTRATOS DOS SERVIÇOS"
echo
echo "Data: $(date)"
echo
} > "$EVIDENCE"

for svc in "${SERVICES[@]}"
do
  echo
  echo "############################################################"
  echo "SERVIÇO: $svc"
  echo "############################################################"

  cd "$UPSTREAM/$svc"

  {
    echo
    echo "============================================================"
    echo "SERVIÇO: $svc"
    echo "============================================================"
    echo
  } >> "$EVIDENCE"

  echo
  echo "===== PORTAS / LISTEN ====="

  grep -RniE \
    'ListenAndServe|:800|PORT|app.run|gunicorn|localhost:' \
    . || true

  {
    echo "## PORTAS / LISTEN"
    grep -RniE \
      'ListenAndServe|:800|PORT|app.run|gunicorn|localhost:' \
      . || true
    echo
  } >> "$EVIDENCE"

  echo
  echo "===== VARIÁVEIS DE AMBIENTE ====="

  grep -RniE \
    'os.Getenv|getenv|os.environ|DATABASE_URL|REDIS|AWS_|SQS|DYNAMO|API_KEY|MASTER_KEY|SERVICE_' \
    . || true

  {
    echo "## VARIÁVEIS DE AMBIENTE"
    grep -RniE \
      'os.Getenv|getenv|os.environ|DATABASE_URL|REDIS|AWS_|SQS|DYNAMO|API_KEY|MASTER_KEY|SERVICE_' \
      . || true
    echo
  } >> "$EVIDENCE"

  echo
  echo "===== ENDPOINTS HTTP ====="

  grep -RniE \
    '"/health"|"/flags"|"/rules"|"/evaluate"|"/validate"|"/admin/keys"' \
    . || true

  {
    echo "## ENDPOINTS HTTP"
    grep -RniE \
      '"/health"|"/flags"|"/rules"|"/evaluate"|"/validate"|"/admin/keys"' \
      . || true
    echo
  } >> "$EVIDENCE"

  echo
  echo "===== CHAMADAS HTTP ====="

  grep -RniE \
    'http://|https://|requests\.|http\.Get|http\.Post|client\.Do' \
    . || true

  {
    echo "## CHAMADAS HTTP"
    grep -RniE \
      'http://|https://|requests\.|http\.Get|http\.Post|client\.Do' \
      . || true
    echo
  } >> "$EVIDENCE"

  echo
  echo "===== POSTGRES / REDIS ====="

  grep -RniE \
    'postgres|psycopg2|pgx|redis|sql.Open|redis.NewClient' \
    . || true

  {
    echo "## POSTGRES / REDIS"
    grep -RniE \
      'postgres|psycopg2|pgx|redis|sql.Open|redis.NewClient' \
      . || true
    echo
  } >> "$EVIDENCE"

  echo
  echo "===== AWS / SQS / DYNAMODB ====="

  grep -RniE \
    'sqs|dynamodb|boto3|session.NewSession|aws\.|AWS_' \
    . || true

  {
    echo "## AWS / SQS / DYNAMODB"
    grep -RniE \
      'sqs|dynamodb|boto3|session.NewSession|aws\.|AWS_' \
      . || true
    echo
  } >> "$EVIDENCE"

done

echo
echo "============================================================"
echo "BLOCO 8 FINALIZADO"
echo "============================================================"

echo
echo "Log:"
echo "$LOG"

echo
echo "Evidência:"
echo "$EVIDENCE"
