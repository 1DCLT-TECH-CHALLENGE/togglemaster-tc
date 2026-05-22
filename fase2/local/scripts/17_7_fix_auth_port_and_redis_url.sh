#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

LOG="$BASE/logs/fase2-bloco17-7-fix-auth-port-redis-url.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-7-correcao-auth-port-redis-url.md"
BACKUP_DIR="$BASE/tmp/backups-bloco17-7-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17.7 - CORREÇÃO AUTH PORT + REDIS_URL"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 17.7 - Correção auth port + Redis URL"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Corrigir a porta interna do auth-service e o formato da REDIS_URL do evaluation-service."
} > "$EVID"

echo
echo "[1/6] Backup do compose"

cp -a "$COMPOSE_FILE" "$BACKUP_DIR/docker-compose.phase2-exec.yaml.bak"
echo "Backup em: $BACKUP_DIR"

echo
echo "[2/6] Aplicando patch no compose"

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

# auth-service estava ouvindo na porta 8001 dentro do container,
# mas o Compose publica host 8001 -> target 8000.
# Melhor padronizar app interno em 8000.
lines = set_env(lines, "auth-service", "PORT", "8000")

# evaluation-service usa redis.ParseURL(), então precisa de scheme.
lines = set_env(lines, "evaluation-service", "REDIS_URL", "redis://redis:6379")
lines = set_env(lines, "evaluation-service", "REDIS_ADDR", "redis:6379")
lines = set_env(lines, "evaluation-service", "REDIS_HOST", "redis")
lines = set_env(lines, "evaluation-service", "REDIS_PORT", "6379")

compose.write_text("\n".join(lines) + "\n")
PY

echo
echo "[3/6] Validando compose renderizado"

cd "$DOCKER_DIR"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" config >/tmp/fase2-compose-rendered-17-7.yaml

echo "OK: docker compose config passou."

echo
echo "Trecho auth-service:"
awk '
  /^  auth-service:/ {show=1}
  /^  [a-zA-Z0-9_-]+:/ && $1 != "auth-service:" && show==1 {show=0}
  show==1 {print}
' /tmp/fase2-compose-rendered-17-7.yaml | tee "$BASE/logs/fase2-bloco17-7-auth-rendered.yaml" | tee -a "$EVID"

echo
echo "Trecho evaluation-service:"
awk '
  /^  evaluation-service:/ {show=1}
  /^  [a-zA-Z0-9_-]+:/ && $1 != "evaluation-service:" && show==1 {show=0}
  show==1 {print}
' /tmp/fase2-compose-rendered-17-7.yaml | tee "$BASE/logs/fase2-bloco17-7-evaluation-rendered.yaml" | tee -a "$EVID"

echo
echo "[4/6] Recriando auth-service e evaluation-service"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --force-recreate auth-service evaluation-service

echo
echo "Aguardando estabilização..."
sleep 20

echo
echo "[5/6] Status dos containers"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps -a \
  | tee "$BASE/logs/fase2-bloco17-7-ps-a.log" \
  | tee -a "$EVID"

echo
echo "[6/6] Health checks"

for port in 8001 8004
do
  echo
  echo "### PORTA $port ###"
  for i in $(seq 1 10)
  do
    if curl -fsS --max-time 5 "http://localhost:$port/health"; then
      echo
      echo "OK: health respondeu na porta $port"
      break
    fi
    echo "Tentativa $i falhou para porta $port; aguardando..."
    sleep 3
  done
done | tee "$BASE/logs/fase2-bloco17-7-health.log" | tee -a "$EVID"

echo
echo "Logs auth-service:"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=80 auth-service \
  | tee "$BASE/logs/fase2-bloco17-7-auth-logs.log" \
  | tee -a "$EVID" || true

echo
echo "Logs evaluation-service:"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=120 evaluation-service \
  | tee "$BASE/logs/fase2-bloco17-7-evaluation-logs.log" \
  | tee -a "$EVID" || true

echo
echo "============================================================"
echo "BLOCO 17.7 FINALIZADO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "Backup: $BACKUP_DIR"
echo "============================================================"
