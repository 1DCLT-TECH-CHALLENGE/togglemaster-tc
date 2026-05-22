#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/togglemaster-tc/fase2"
REPOS="$BASE/repos/upstream"
DOCKER_DIR="$BASE/docker"
LOG="$BASE/logs/fase2-bloco6-docker-assets.log"

exec > >(tee "$LOG") 2>&1

echo "== BLOCO 6: Preparando Dockerfiles e docker-compose local =="

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    cp "$file" "$file.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

create_python_dockerfile() {
  local service="$1"
  local port="$2"
  local dir="$REPOS/$service"

  backup_file "$dir/Dockerfile"

  cat > "$dir/Dockerfile" <<EOF_DOCKER
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \\
    && apt-get install -y --no-install-recommends gcc libpq-dev curl \\
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python -m pip install --upgrade "pip<26" \\
    && pip install --no-cache-dir -r requirements.txt \\
    && pip install --no-cache-dir gunicorn

COPY . .

EXPOSE $port

CMD ["gunicorn", "--bind", "0.0.0.0:$port", "app:app"]
EOF_DOCKER
}

create_go_dockerfile() {
  local service="$1"
  local port="$2"
  local dir="$REPOS/$service"

  backup_file "$dir/Dockerfile"

  cat > "$dir/Dockerfile" <<EOF_DOCKER
FROM golang:1.22 AS builder

WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN go build -o /app/service .

FROM debian:bookworm-slim

WORKDIR /app
RUN apt-get update \\
    && apt-get install -y --no-install-recommends ca-certificates curl \\
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/service /app/service

EXPOSE $port

CMD ["/app/service"]
EOF_DOCKER
}

prepare_service() {
  local service="$1"
  local port="$2"
  local dir="$REPOS/$service"

  echo
  echo "### Serviço: $service"

  if [ ! -d "$dir" ]; then
    echo "ERRO: diretório não encontrado: $dir"
    exit 1
  fi

  if [ -f "$dir/go.mod" ]; then
    echo "Detectado Go"
    create_go_dockerfile "$service" "$port"
  elif [ -f "$dir/requirements.txt" ]; then
    echo "Detectado Python"
    create_python_dockerfile "$service" "$port"
  else
    echo "ERRO: não consegui detectar stack de $service"
    exit 1
  fi
}

prepare_service "auth-service" "8001"
prepare_service "flag-service" "8002"
prepare_service "targeting-service" "8003"
prepare_service "evaluation-service" "8004"
prepare_service "analytics-service" "8005"

cat > "$DOCKER_DIR/docker-compose.core.yaml" <<'EOF_COMPOSE'
services:
  postgres-auth:
    image: postgres:13
    environment:
      POSTGRES_DB: auth_db
      POSTGRES_USER: auth_user
      POSTGRES_PASSWORD: auth_pass
    ports:
      - "5433:5432"
    volumes:
      - postgres_auth_data:/var/lib/postgresql/data

  postgres-flags:
    image: postgres:13
    environment:
      POSTGRES_DB: flags_db
      POSTGRES_USER: flags_user
      POSTGRES_PASSWORD: flags_pass
    ports:
      - "5434:5432"
    volumes:
      - postgres_flags_data:/var/lib/postgresql/data

  postgres-targeting:
    image: postgres:13
    environment:
      POSTGRES_DB: targeting_db
      POSTGRES_USER: targeting_user
      POSTGRES_PASSWORD: targeting_pass
    ports:
      - "5435:5432"
    volumes:
      - postgres_targeting_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  auth-service:
    build:
      context: ../repos/upstream/auth-service
    environment:
      DATABASE_URL: postgres://auth_user:auth_pass@postgres-auth:5432/auth_db?sslmode=disable
      PORT: 8001
      MASTER_KEY: local-master-key
    ports:
      - "8001:8001"
    depends_on:
      - postgres-auth

  flag-service:
    build:
      context: ../repos/upstream/flag-service
    environment:
      DATABASE_URL: postgresql://flags_user:flags_pass@postgres-flags:5432/flags_db
      PORT: 8002
      SERVICE_API_KEY: ${SERVICE_API_KEY:-}
    ports:
      - "8002:8002"
    depends_on:
      - postgres-flags

  targeting-service:
    build:
      context: ../repos/upstream/targeting-service
    environment:
      DATABASE_URL: postgresql://targeting_user:targeting_pass@postgres-targeting:5432/targeting_db
      PORT: 8003
      SERVICE_API_KEY: ${SERVICE_API_KEY:-}
    ports:
      - "8003:8003"
    depends_on:
      - postgres-targeting

  evaluation-service:
    build:
      context: ../repos/upstream/evaluation-service
    environment:
      PORT: 8004
      REDIS_URL: redis:6379
      FLAG_SERVICE_URL: http://flag-service:8002
      TARGETING_SERVICE_URL: http://targeting-service:8003
      SERVICE_API_KEY: ${SERVICE_API_KEY:-}
    ports:
      - "8004:8004"
    depends_on:
      - redis
      - flag-service
      - targeting-service

volumes:
  postgres_auth_data:
  postgres_flags_data:
  postgres_targeting_data:
EOF_COMPOSE

echo
echo "Validando docker compose..."
cd "$DOCKER_DIR"
docker compose -f docker-compose.core.yaml config >/dev/null

echo
echo "BLOCO 6 concluído com sucesso."
echo "Log: $LOG"
