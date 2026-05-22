#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"

UPSTREAM="$BASE/repos/upstream"
SRC="$BASE/src/services"

DOCKER_DIR="$BASE/docker"
LOG_DIR="$BASE/logs"

LOG="$LOG_DIR/fase2-bloco11-prepare-executable.log"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 11 - PREPARAÇÃO EXECUTÁVEL"
echo "============================================================"

mkdir -p "$SRC"
mkdir -p "$DOCKER_DIR"

echo
echo "[1/7] Criando working copies"

for svc in \
  auth-service \
  flag-service \
  targeting-service \
  evaluation-service \
  analytics-service
do
  echo
  echo "### $svc ###"

  rm -rf "$SRC/$svc"
  cp -R "$UPSTREAM/$svc" "$SRC/$svc"
done

echo
echo "[2/7] Gerando Dockerfiles Python"

for svc in \
  flag-service \
  targeting-service \
  analytics-service
do
cat > "$SRC/$svc/Dockerfile" <<'PYEOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      gcc \
      libpq-dev \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python -m pip install --upgrade "pip<26" \
 && pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir gunicorn

COPY . .

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
PYEOF
done

echo
echo "[3/7] Gerando Dockerfiles Go"

for svc in \
  auth-service \
  evaluation-service
do
cat > "$SRC/$svc/Dockerfile" <<'GOEOF'
FROM golang:1.22 AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum* ./

RUN go mod download || true

COPY . .

RUN go build -o service .

FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/service /app/service

EXPOSE 8000

CMD ["/app/service"]
GOEOF
done

echo
echo "[4/7] Gerando compose executável"

cat > "$DOCKER_DIR/docker-compose.phase2-exec.yaml" <<'COMPOSEEOF'
version: "3.9"

services:

  postgres-auth:
    image: postgres:13
    environment:
      POSTGRES_USER: auth_user
      POSTGRES_PASSWORD: auth_pass
      POSTGRES_DB: auth_db
    ports:
      - "5433:5432"

  postgres-flags:
    image: postgres:13
    environment:
      POSTGRES_USER: flags_user
      POSTGRES_PASSWORD: flags_pass
      POSTGRES_DB: flags_db
    ports:
      - "5434:5432"

  postgres-targeting:
    image: postgres:13
    environment:
      POSTGRES_USER: targeting_user
      POSTGRES_PASSWORD: targeting_pass
      POSTGRES_DB: targeting_db
    ports:
      - "5435:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  localstack:
    image: localstack/localstack:3.8.1
    environment:
      - SERVICES=sqs,dynamodb
    ports:
      - "4566:4566"

  auth-service:
    build:
      context: ../src/services/auth-service
    ports:
      - "8001:8000"

  flag-service:
    build:
      context: ../src/services/flag-service
    ports:
      - "8002:8000"

  targeting-service:
    build:
      context: ../src/services/targeting-service
    ports:
      - "8003:8000"

  evaluation-service:
    build:
      context: ../src/services/evaluation-service
    environment:
      - AWS_REGION=us-east-1
      - AWS_ENDPOINT_URL=http://localstack:4566
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
    ports:
      - "8004:8000"

  analytics-service:
    build:
      context: ../src/services/analytics-service
    environment:
      - AWS_REGION=us-east-1
      - AWS_ENDPOINT_URL=http://localstack:4566
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
    ports:
      - "8005:8000"
COMPOSEEOF

echo
echo "[5/7] Validando compose"

cd "$DOCKER_DIR"

docker compose -f docker-compose.phase2-exec.yaml config >/dev/null

echo
echo "[6/7] Estrutura final"

find "$SRC" -maxdepth 2 -name Dockerfile | sort

echo
echo "[7/7] Finalizado"

echo
echo "Compose:"
echo "$DOCKER_DIR/docker-compose.phase2-exec.yaml"

echo
echo "============================================================"
echo "BLOCO 11 FINALIZADO"
echo "============================================================"
