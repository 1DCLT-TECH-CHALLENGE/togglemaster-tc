#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"

cd "${APP_DIR}"

echo "[INFO] Resetando Fase 1..."
docker compose down -v --remove-orphans
echo "[OK] Reset concluído."
