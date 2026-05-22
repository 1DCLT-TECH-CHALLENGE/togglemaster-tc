#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

LOG="$BASE/logs/fase2-bloco17-8-fix-evaluation-port.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-8-correcao-porta-evaluation.md"
BACKUP_DIR="$BASE/tmp/backups-bloco17-8-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17.8 - CORREÇÃO PORTA INTERNA EVALUATION"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 17.8 - Correção porta interna evaluation-service"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Padronizar o evaluation-service para escutar internamente na porta 8000, alinhado ao mapeamento host 8004 -> container 8000."
} > "$EVID"

echo
echo "[1/5] Backup do compose"

cp -a "$COMPOSE_FILE" "$BACKUP_DIR/docker-compose.phase2-exec.yaml.bak"
echo "Backup em: $BACKUP_DIR"

echo
echo "[2/5] Aplicando PORT=8000 no evaluation-service"

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
    if insert_at < len(lines) and lines[insert_at].startswith("    restart:"):
        insert_at += 1

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

lines = set_env(lines, "evaluation-service", "PORT", "8000")

compose.write_text("\n".join(lines) + "\n")
PY

echo
echo "[3/5] Validando compose renderizado"

cd "$DOCKER_DIR"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" config >/tmp/fase2-compose-rendered-17-8.yaml

awk '
  /^  evaluation-service:/ {show=1}
  /^  [a-zA-Z0-9_-]+:/ && $1 != "evaluation-service:" && show==1 {show=0}
  show==1 {print}
' /tmp/fase2-compose-rendered-17-8.yaml | tee "$BASE/logs/fase2-bloco17-8-evaluation-rendered.yaml" | tee -a "$EVID"

echo
echo "[4/5] Recriando evaluation-service"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --force-recreate evaluation-service

echo
echo "Aguardando estabilização..."
sleep 15

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps -a \
  | tee "$BASE/logs/fase2-bloco17-8-ps-a.log" \
  | tee -a "$EVID"

echo
echo "[5/5] Health check evaluation-service"

for i in $(seq 1 10)
do
  if curl -fsS --max-time 5 http://localhost:8004/health; then
    echo
    echo "OK: evaluation-service respondeu health na porta 8004"
    break
  fi

  echo "Tentativa $i falhou; aguardando..."
  sleep 3
done | tee "$BASE/logs/fase2-bloco17-8-health-evaluation.log" | tee -a "$EVID"

echo
echo "Logs recentes evaluation-service:"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=80 evaluation-service \
  | tee "$BASE/logs/fase2-bloco17-8-evaluation-logs.log" \
  | tee -a "$EVID" || true

echo
echo "============================================================"
echo "BLOCO 17.8 FINALIZADO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "Backup: $BACKUP_DIR"
echo "============================================================"
