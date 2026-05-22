#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
LOG="$BASE/logs/fase2-bloco14-diagnose-stack.log"
EVID="$BASE/docs/evidencias/fase2-diagnostico-pos-subida.md"

COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 14 - DIAGNÓSTICO ESSENCIAL PÓS-SUBIDA"
echo "============================================================"

cd "$DOCKER_DIR"

{
  echo "# Fase 2 - Diagnóstico Pós-Subida"
  echo
  echo "Data: $(date)"
  echo
} > "$EVID"

echo
echo "[1/5] Status do compose"
docker compose -f "$COMPOSE_FILE" ps | tee -a "$EVID"

echo
echo "[2/5] Containers ativos"
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | tee -a "$EVID"

echo
echo "[3/5] Health checks HTTP"
for port in 8001 8002 8003 8004 8005
do
  echo
  echo "### PORTA $port ###"
  curl -i -s --max-time 5 "http://localhost:$port/health" || true
done | tee -a "$EVID"

echo
echo "[4/5] Logs recentes dos serviços"
for svc in \
  auth-service \
  flag-service \
  targeting-service \
  evaluation-service \
  analytics-service \
  postgres-auth \
  postgres-flags \
  postgres-targeting \
  redis \
  localstack
do
  echo
  echo "============================================================"
  echo "LOGS: $svc"
  echo "============================================================"
  docker compose -f "$COMPOSE_FILE" logs --tail=80 "$svc" || true
done | tee -a "$EVID"

echo
echo "[5/5] Imagens criadas"
docker images | grep -E 'auth-service|flag-service|targeting-service|evaluation-service|analytics-service|localstack|postgres|redis' || true

echo
echo "============================================================"
echo "BLOCO 14 FINALIZADO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "============================================================"
