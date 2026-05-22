#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"

cd "${APP_DIR}"

echo "[INFO] Subindo Fase 1..."
docker compose up -d --build

echo "[INFO] Aguardando /health responder..."
for i in $(seq 1 30); do
  if curl -fsS http://localhost:5000/health >/dev/null 2>&1; then
    echo "[OK] Aplicação respondeu em /health."
    docker compose ps
    exit 0
  fi
  echo "[INFO] Tentativa ${i}/30: aplicação ainda não respondeu."
  sleep 2
done

echo "[ERRO] Aplicação não respondeu em /health após 60s."
docker compose ps
docker compose logs app --tail=80
exit 1
