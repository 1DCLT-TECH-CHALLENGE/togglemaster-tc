#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
LOG="$BASE/logs/fase2-bloco7-up-core.log"

exec > >(tee "$LOG") 2>&1

echo "=================================================="
echo "FASE 2 - BLOCO 7 - SUBIDA DO CORE LOCAL"
echo "=================================================="

cd "$DOCKER_DIR"

echo
echo "== Docker compose config =="
docker compose -f docker-compose.core.yaml config >/dev/null

echo
echo "== Buildando imagens =="
docker compose -f docker-compose.core.yaml build --no-cache

echo
echo "== Subindo ambiente =="
docker compose -f docker-compose.core.yaml up -d

echo
echo "== Containers ativos =="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo
echo "== Health checks iniciais =="

sleep 15

for port in 8001 8002 8003 8004
do
  echo
  echo "### Porta $port ###"

  curl -s http://localhost:$port/health || true
done

echo
echo "=================================================="
echo "BLOCO 7 FINALIZADO"
echo "Log salvo em:"
echo "$LOG"
echo "=================================================="
