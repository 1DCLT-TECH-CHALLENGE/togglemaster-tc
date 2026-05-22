#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

LOG="$BASE/logs/fase2-bloco17-6-fix-startup-race-redis.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-6-correcao-startup-redis.md"
BACKUP_DIR="$BASE/tmp/backups-bloco17-6-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17.6 - CORREÇÃO STARTUP RACE + REDIS ENV"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 17.6 - Correção startup race + Redis env"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Corrigir a corrida de inicialização do auth-service com PostgreSQL e o endereço Redis do evaluation-service."
  echo
} > "$EVID"

echo
echo "[1/7] Backup do compose"

cp -a "$COMPOSE_FILE" "$BACKUP_DIR/docker-compose.phase2-exec.yaml.bak"

echo "Backup em: $BACKUP_DIR"

echo
echo "[2/7] Inspecionando variáveis Redis esperadas no evaluation-service"

grep -R --line-number -E 'REDIS|Redis|redis|Getenv|localhost:6379|127.0.0.1:6379' \
  "$BASE/src/services/evaluation-service" \
  | tee "$BASE/logs/fase2-bloco17-6-grep-evaluation-redis.log" \
  | tee -a "$EVID" || true

echo
echo "[3/7] Aplicando patch cirúrgico no docker-compose"

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
        raise SystemExit(f"Serviço não encontrado no compose: {service}")

    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("  ") and not lines[j].startswith("    ") and lines[j].strip().endswith(":"):
            end = j
            break
    return start, end

def ensure_restart(lines, service):
    start, end = find_service_block(lines, service)
    block = lines[start:end]
    if any(l.startswith("    restart:") for l in block):
        return lines

    lines.insert(start + 1, "    restart: unless-stopped")
    return lines

def ensure_environment_mapping(lines, service):
    start, end = find_service_block(lines, service)
    block = lines[start:end]

    env_idx = None
    for i in range(start, end):
        if lines[i].startswith("    environment:"):
            env_idx = i
            break

    if env_idx is None:
        insert_at = start + 1
        if lines[insert_at].startswith("    restart:"):
            insert_at += 1
        lines.insert(insert_at, "    environment:")
        return lines, insert_at

    return lines, env_idx

def ensure_env_key(lines, service, key, value):
    lines, env_idx = ensure_environment_mapping(lines, service)
    start, end = find_service_block(lines, service)

    # Se já existe a chave em formato map ou list, atualiza para formato map.
    for i in range(env_idx + 1, end):
        stripped = lines[i].strip()

        if stripped.startswith(f"{key}:"):
            lines[i] = f"      {key}: \"{value}\""
            return lines

        if stripped.startswith(f"- {key}="):
            lines[i] = f"      {key}: \"{value}\""
            return lines

    # Insere logo após environment:
    lines.insert(env_idx + 1, f"      {key}: \"{value}\"")
    return lines

# Corrige corrida de startup: se morrer cedo, reinicia.
for svc in ["auth-service", "evaluation-service"]:
    lines = ensure_restart(lines, svc)

# Garante variáveis mais comuns para Redis. Se o código usa qualquer uma delas,
# apontará para o serviço Docker correto.
for key, value in [
    ("REDIS_ADDR", "redis:6379"),
    ("REDIS_URL", "redis:6379"),
    ("REDIS_HOST", "redis"),
    ("REDIS_PORT", "6379"),
]:
    lines = ensure_env_key(lines, "evaluation-service", key, value)

compose.write_text("\n".join(lines) + "\n")
PY

echo
echo "[4/7] Validando compose renderizado"

cd "$DOCKER_DIR"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" config >/tmp/fase2-compose-rendered.yaml

echo "OK: docker compose config passou."

echo
echo "Trecho evaluation-service renderizado:"
awk '
  /^  evaluation-service:/ {show=1}
  /^  [a-zA-Z0-9_-]+:/ && $1 != "evaluation-service:" && show==1 {show=0}
  show==1 {print}
' /tmp/fase2-compose-rendered.yaml | tee "$BASE/logs/fase2-bloco17-6-evaluation-rendered.yaml" | tee -a "$EVID"

echo
echo "Trecho auth-service renderizado:"
awk '
  /^  auth-service:/ {show=1}
  /^  [a-zA-Z0-9_-]+:/ && $1 != "auth-service:" && show==1 {show=0}
  show==1 {print}
' /tmp/fase2-compose-rendered.yaml | tee "$BASE/logs/fase2-bloco17-6-auth-rendered.yaml" | tee -a "$EVID"

echo
echo "[5/7] Recriando auth-service e evaluation-service"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --force-recreate auth-service evaluation-service

echo
echo "Aguardando serviços estabilizarem..."
sleep 20

echo
echo "[6/7] Status após recriação"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps -a \
  | tee "$BASE/logs/fase2-bloco17-6-ps-a.log" \
  | tee -a "$EVID"

echo
echo "[7/7] Health checks dos serviços corrigidos"

for port in 8001 8004
do
  echo
  echo "### PORTA $port ###"
  curl -i -s --max-time 10 "http://localhost:$port/health" || true
done | tee "$BASE/logs/fase2-bloco17-6-health-auth-eval.log" | tee -a "$EVID"

echo
echo "Logs recentes auth-service:"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=80 auth-service \
  | tee "$BASE/logs/fase2-bloco17-6-auth-logs.log" \
  | tee -a "$EVID" || true

echo
echo "Logs recentes evaluation-service:"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=80 evaluation-service \
  | tee "$BASE/logs/fase2-bloco17-6-evaluation-logs.log" \
  | tee -a "$EVID" || true

echo
echo "============================================================"
echo "BLOCO 17.6 FINALIZADO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "Backup: $BACKUP_DIR"
echo "============================================================"
