#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"

DOCKER_DIR="$BASE/docker"
LOG_DIR="$BASE/logs"

LOG="$LOG_DIR/fase2-bloco13-up-stack.log"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 13 - PRIMEIRA SUBIDA CONSOLIDADA"
echo "============================================================"

COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "ERRO: compose não encontrado:"
  echo "$COMPOSE_FILE"
  exit 1
fi

echo
echo "[1/7] Validando compose"

cd "$DOCKER_DIR"

docker compose -f "$COMPOSE_FILE" config >/dev/null

echo
echo "[2/7] Buildando imagens"

docker compose -f "$COMPOSE_FILE" build --no-cache

echo
echo "[3/7] Subindo stack"

docker compose -f "$COMPOSE_FILE" up -d

echo
echo "[4/7] Containers ativos"

docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo
echo "[5/7] Aguardando estabilização"

sleep 20

echo
echo "[6/7] Health checks"

for port in 8001 8002 8003 8004 8005
do
  echo
  echo "### PORTA $port ###"

  curl -s http://localhost:$port/health || true
done

echo
echo "[7/7] Logs resumidos"

docker compose -f "$COMPOSE_FILE" ps

echo
echo "============================================================"
echo "SUBIDA CONSOLIDADA FINALIZADA"
echo "LOG:"
echo "$LOG"
echo "============================================================"
