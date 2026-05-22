#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"

cd "${FASE1_DIR}"

echo "[INFO] Validação completa da Fase 1 iniciada."

./local/scripts/01_up.sh
./local/scripts/02_test_api.sh
./local/scripts/03_down.sh

echo "[OK] Validação completa da Fase 1 concluída com sucesso."
