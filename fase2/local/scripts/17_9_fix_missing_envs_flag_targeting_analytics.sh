#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

LOG="$BASE/logs/fase2-bloco17-9-fix-missing-envs.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-9-correcao-envs-servicos-python.md"
BACKUP_DIR="$BASE/tmp/backups-bloco17-9-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17.9 - CORREÇÃO ENVS PYTHON SERVICES"
echo "============================================================"
echo "Data: $(date)"
echo

cp -a "$COMPOSE_FILE" "$BACKUP_DIR/docker-compose.phase2-exec.yaml.bak"
echo "Backup em: $BACKUP_DIR"

python3 - "$COMPOSE_FILE" <<'PY'
from pathlib import Path
import sys

compose = Path(sys.argv[1])
lines = compose.read_text().splitlines()

def find_service_block(lines, service):
    start = None
    for i, line in enumerate(lines):
        if line.strip() == f"{service}:" and line.startswith("  "):
            start = i
            break
    if start is None:
        raise SystemExit(f"Serviço não encontrado: {service}")

    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("  ") and not lines[j].startswith("    ") and lines[j].strip().endswith(":"):
            end = j
            break

    return start, end

def ensure_environment(lines, service):
    start, end = find_service_block(lines, service)

    for i in range(start, end):
        if lines[i].startswith("    environment:"):
            return lines, i

    insert_at = start + 1
    lines.insert(insert_at, "    environment:")
    return lines, insert_at

def set_env(lines, service, key, value):
    lines, env_idx = ensure_environment(lines, service)
    start, end = find_service_block(lines, service)

    for i in range(env_idx + 1, end):
        stripped = lines[i].strip()

        if stripped.startswith(f"{key}:"):
            lines[i] = f'      {key}: "{value}"'
            return lines

        if stripped.startswith(f"- {key}="):
            lines[i] = f'      {key}: "{value}"'
            return lines

    lines.insert(env_idx + 1, f'      {key}: "{value}"')
    return lines

def ensure_restart(lines, service):
    start, end = find_service_block(lines, service)
    block = lines[start:end]

    if any(l.startswith("    restart:") for l in block):
        return lines

    lines.insert(start + 1, "    restart: unless-stopped")
    return lines

for svc in ["flag-service", "targeting-service", "analytics-service"]:
    lines = ensure_restart(lines, svc)

lines = set_env(lines, "flag-service", "AUTH_SERVICE_URL", "http://auth-service:8000")
lines = set_env(lines, "targeting-service", "AUTH_SERVICE_URL", "http://auth-service:8000")
lines = set_env(lines, "analytics-service", "AWS_DYNAMODB_TABLE", "ToggleMasterAnalytics")

compose.write_text("\n".join(lines) + "\n")
PY

echo
echo "Validando compose renderizado..."
cd "$DOCKER_DIR"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" config >/tmp/fase2-compose-rendered-17-9.yaml

echo "OK: docker compose config passou."

echo
echo "Trechos relevantes renderizados:"
awk '
  /^  flag-service:/ {show=1}
  /^  targeting-service:/ {show=1}
  /^  analytics-service:/ {show=1}
  /^  [a-zA-Z0-9_-]+:/ && $1 !~ /^(flag-service:|targeting-service:|analytics-service:)$/ && show==1 {show=0}
  show==1 {print}
' /tmp/fase2-compose-rendered-17-9.yaml | tee "$BASE/logs/fase2-bloco17-9-compose-rendered.yaml"

{
  echo "# Fase 2 - BLOCO 17.9 - Correção de variáveis dos serviços Python"
  echo
  echo "Data: $(date)"
  echo
  echo "## Resultado"
  echo "- Adicionado AUTH_SERVICE_URL em flag-service."
  echo "- Adicionado AUTH_SERVICE_URL em targeting-service."
  echo "- Adicionado AWS_DYNAMODB_TABLE em analytics-service."
  echo "- Adicionado restart: unless-stopped nos serviços Python."
  echo "- docker compose config validado com sucesso."
  echo
  echo "## Arquivos"
  echo "- Log: \`$LOG\`"
  echo "- Backup: \`$BACKUP_DIR\`"
  echo "- Compose renderizado: \`$BASE/logs/fase2-bloco17-9-compose-rendered.yaml\`"
} > "$EVID"

echo
echo "============================================================"
echo "BLOCO 17.9 FINALIZADO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "Backup: $BACKUP_DIR"
echo "============================================================"
