#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"

cd "${APP_DIR}"

echo "[INFO] Parando Fase 1..."
docker compose down
echo "[OK] Containers parados."
