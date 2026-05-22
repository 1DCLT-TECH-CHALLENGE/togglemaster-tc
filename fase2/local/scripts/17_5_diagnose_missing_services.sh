#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

LOG="$BASE/logs/fase2-bloco17-5-diagnose-missing-services.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-5-diagnostico-servicos-ausentes.md"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17.5 - DIAGNÓSTICO DE SERVIÇOS AUSENTES"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 17.5 - Diagnóstico de serviços ausentes"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Diagnosticar por que auth-service e evaluation-service não aparecem como Up após o BLOCO 16."
  echo
} > "$EVID"

cd "$DOCKER_DIR"

echo
echo "[1/6] docker compose ps"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps | tee -a "$EVID"

echo
echo "[2/6] docker compose ps -a"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps -a | tee "$BASE/logs/fase2-bloco17-5-ps-a.log" | tee -a "$EVID"

echo
echo "[3/6] Logs auth-service"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=160 auth-service \
  | tee "$BASE/logs/fase2-bloco17-5-auth-service.log" \
  | tee -a "$EVID" || true

echo
echo "[4/6] Logs evaluation-service"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=160 evaluation-service \
  | tee "$BASE/logs/fase2-bloco17-5-evaluation-service.log" \
  | tee -a "$EVID" || true

echo
echo "[5/6] Logs postgres-auth e redis"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=120 postgres-auth redis \
  | tee "$BASE/logs/fase2-bloco17-5-dependencies.log" \
  | tee -a "$EVID" || true

echo
echo "[6/6] Inspecionando exit code dos containers relevantes"

for c in docker-auth-service-1 docker-evaluation-service-1
do
  echo
  echo "### $c ###"
  docker inspect "$c" \
    --format 'Name={{.Name}} Status={{.State.Status}} ExitCode={{.State.ExitCode}} Error={{.State.Error}} StartedAt={{.State.StartedAt}} FinishedAt={{.State.FinishedAt}}' \
    2>/dev/null || echo "Container não encontrado: $c"
done | tee "$BASE/logs/fase2-bloco17-5-exit-codes.log" | tee -a "$EVID"

echo
echo "============================================================"
echo "BLOCO 17.5 FINALIZADO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "============================================================"
