#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
UPSTREAM="$BASE/repos/upstream"
LOG="$BASE/logs/fase2-runtime-matrix.log"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - EXTRAÇÃO DA MATRIZ OPERACIONAL FINAL"
echo "============================================================"

for svc in \
  auth-service \
  flag-service \
  targeting-service \
  evaluation-service \
  analytics-service
do
  echo
  echo "############################################################"
  echo "SERVIÇO: $svc"
  echo "############################################################"

  cd "$UPSTREAM/$svc"

  echo
  echo "================ README ================="
  [ -f README.md ] && cat README.md

  echo
  echo "================ PORTAS ================="
  grep -RniE \
    'ListenAndServe|:800|PORT|app.run|gunicorn|localhost:' \
    . || true

  echo
  echo "================ ENV VARS ================="
  grep -RniE \
    'os.Getenv|getenv|os.environ|DATABASE_URL|REDIS|AWS_|SQS|DYNAMO|API_KEY|MASTER_KEY|SERVICE_' \
    . || true

  echo
  echo "================ ROTAS / ENDPOINTS ================="
  grep -RniE \
    '"/health"|"/flags"|"/rules"|"/evaluate"|"/validate"|"/admin/keys"' \
    . || true

  echo
  echo "================ CHAMADAS HTTP ================="
  grep -RniE \
    'http://|https://|requests\.|http\.Get|http\.Post|client\.Do' \
    . || true

  echo
  echo "================ REDIS ================="
  grep -RniE \
    'redis|redis.NewClient' \
    . || true

  echo
  echo "================ POSTGRES ================="
  grep -RniE \
    'postgres|psycopg2|pgx|sql.Open' \
    . || true

  echo
  echo "================ SQS / DYNAMODB ================="
  grep -RniE \
    'sqs|dynamodb|boto3|session.NewSession|AWS_' \
    . || true

done

echo
echo "============================================================"
echo "EXTRAÇÃO FINALIZADA"
echo "LOG:"
echo "$LOG"
echo "============================================================"
