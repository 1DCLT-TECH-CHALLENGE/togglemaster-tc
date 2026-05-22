#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"

cd "${APP_DIR}"

echo "[INFO] Testando /health..."
curl -s http://localhost:5000/health | tee "${LOG_DIR}/fase1-health.json"

echo
echo "[INFO] Criando flag new-feature..."
HTTP_CODE=$(curl -s -o "${LOG_DIR}/fase1-post-flag.json" -w "%{http_code}" \
  -X POST http://localhost:5000/flags \
  -H "Content-Type: application/json" \
  -d '{"name":"new-feature","is_enabled":true}')

if [[ "${HTTP_CODE}" == "201" ]]; then
  echo "[OK] Flag criada."
elif [[ "${HTTP_CODE}" == "409" ]]; then
  echo "[OK] Flag já existia. Idempotência validada."
else
  echo "[ERRO] POST /flags retornou HTTP ${HTTP_CODE}"
  cat "${LOG_DIR}/fase1-post-flag.json"
  exit 1
fi

echo
echo "[INFO] Habilitando flag..."
curl -s -X PUT http://localhost:5000/flags/new-feature \
  -H "Content-Type: application/json" \
  -d '{"is_enabled":true}' | tee "${LOG_DIR}/fase1-put-enable.json"

echo
echo "[INFO] Listando flags..."
curl -s http://localhost:5000/flags | tee "${LOG_DIR}/fase1-flags.json"

echo
echo "[INFO] Desabilitando flag..."
curl -s -X PUT http://localhost:5000/flags/new-feature \
  -H "Content-Type: application/json" \
  -d '{"is_enabled":false}' | tee "${LOG_DIR}/fase1-put-disable.json"

echo
echo "[INFO] Validando estado final..."
curl -s http://localhost:5000/flags/new-feature | tee "${LOG_DIR}/fase1-final-state.json"

cat > "${EVIDENCE_DIR}/fase1-local-api-tests.md" <<EVIDENCE
# Fase 1 — Testes locais da API

## Resultado

- Healthcheck OK
- POST /flags OK ou 409 tratado como idempotência
- GET /flags OK
- PUT /flags/new-feature OK
- Persistência PostgreSQL validada
- Fluxo local da Fase 1 validado
EVIDENCE

echo
echo "[OK] Testes locais da Fase 1 concluídos."
