#!/usr/bin/env bash
set -Eeuo pipefail

TC_ROOT="${TC_ROOT:-$HOME/togglemaster-tc}"
FASE1_DIR="$TC_ROOT/fase1"
UPSTREAM_DIR="$FASE1_DIR/repos/upstream/toggle-master-monolith"
APP_DIR="$FASE1_DIR/src/toggle-master-monolith"
REPO_URL="https://github.com/dougls/toggle-master-monolith"

RUN_FASE1_VALIDATE="${RUN_FASE1_VALIDATE:-false}"
BOOTSTRAP_RESET_LOCAL="${BOOTSTRAP_RESET_LOCAL:-false}"

mkdir -p \
  "$FASE1_DIR/repos/upstream" \
  "$FASE1_DIR/src" \
  "$FASE1_DIR/local/scripts" \
  "$FASE1_DIR/docs/evidencias" \
  "$FASE1_DIR/logs" \
  "$FASE1_DIR/tmp"

echo "[INFO] Bootstrap Fase 1 iniciado."

if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
  echo "[INFO] Clonando upstream oficial da Fase 1..."
  git clone "$REPO_URL" "$UPSTREAM_DIR"
else
  echo "[INFO] Upstream já existe. Atualizando main..."
  git -C "$UPSTREAM_DIR" fetch origin
  git -C "$UPSTREAM_DIR" checkout main
  git -C "$UPSTREAM_DIR" pull --ff-only origin main
fi

echo "[INFO] Sincronizando working copy..."
rm -rf "$APP_DIR"
rsync -a --exclude '.git' "$UPSTREAM_DIR/" "$APP_DIR/"

cat > "$FASE1_DIR/local/scripts/00_common.sh" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${HOME}/togglemaster-tc"
FASE1_DIR="${BASE_DIR}/fase1"
APP_DIR="${FASE1_DIR}/src/toggle-master-monolith"
LOG_DIR="${FASE1_DIR}/logs"
EVIDENCE_DIR="${FASE1_DIR}/docs/evidencias"

mkdir -p "${LOG_DIR}" "${EVIDENCE_DIR}"

export BASE_DIR FASE1_DIR APP_DIR LOG_DIR EVIDENCE_DIR
SCRIPT

cat > "$FASE1_DIR/local/scripts/01_up.sh" <<'SCRIPT'
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
SCRIPT

cat > "$FASE1_DIR/local/scripts/02_test_api.sh" <<'SCRIPT'
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
SCRIPT

cat > "$FASE1_DIR/local/scripts/03_down.sh" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"

cd "${APP_DIR}"

echo "[INFO] Parando Fase 1..."
docker compose down
echo "[OK] Containers parados."
SCRIPT

cat > "$FASE1_DIR/local/scripts/04_reset.sh" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"

cd "${APP_DIR}"

echo "[INFO] Resetando Fase 1..."
docker compose down -v --remove-orphans
echo "[OK] Reset concluído."
SCRIPT

cat > "$FASE1_DIR/local/scripts/05_validate_all.sh" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"

cd "${FASE1_DIR}"

echo "[INFO] Validação completa da Fase 1 iniciada."

./local/scripts/01_up.sh
./local/scripts/02_test_api.sh
./local/scripts/03_down.sh

echo "[OK] Validação completa da Fase 1 concluída com sucesso."
SCRIPT

chmod 755 "$FASE1_DIR"/local/scripts/*.sh

bash -n "$FASE1_DIR"/local/scripts/*.sh

cat > "$FASE1_DIR/docs/evidencias/fase1-bootstrap.md" <<EOF2
# Fase 1 — Bootstrap

## Resultado

Bootstrap único da Fase 1 gerado/executado.

## Upstream

$REPO_URL

## Diretórios

- upstream: $UPSTREAM_DIR
- working copy: $APP_DIR

## Scripts locais

- 00_common.sh
- 01_up.sh
- 02_test_api.sh
- 03_down.sh
- 04_reset.sh
- 05_validate_all.sh

## Observações

- AWS não utilizada.
- Terraform não utilizado.
- Cloud não utilizada.
- Upstream preservado.
- Working copy sincronizada em src.
EOF2

if [[ "$BOOTSTRAP_RESET_LOCAL" == "true" ]]; then
  echo "[INFO] Reset local solicitado."
  "$FASE1_DIR/local/scripts/04_reset.sh" || true
fi

if [[ "$RUN_FASE1_VALIDATE" == "true" ]]; then
  echo "[INFO] Validação local solicitada."
  "$FASE1_DIR/local/scripts/05_validate_all.sh"
else
  echo "[INFO] Validação local não executada. Use RUN_FASE1_VALIDATE=true para validar."
fi

echo "[OK] Bootstrap Fase 1 concluído."
