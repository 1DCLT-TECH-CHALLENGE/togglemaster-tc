#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"

INPUT_LOG="$BASE/logs/fase2-runtime-matrix.log"
OUTPUT_MD="$BASE/docs/evidencias/fase2-runtime-matrix-consolidada.md"
LOG="$BASE/logs/fase2-bloco9-consolidate-runtime-matrix.log"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 9 - CONSOLIDAÇÃO DA MATRIZ OPERACIONAL"
echo "============================================================"

if [ ! -f "$INPUT_LOG" ]; then
  echo "ERRO: log não encontrado:"
  echo "$INPUT_LOG"
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_MD")"

{
  echo "# Fase 2 - Runtime Matrix Consolidada"
  echo
  echo "Gerado em: $(date)"
  echo

  for svc in \
    auth-service \
    flag-service \
    targeting-service \
    evaluation-service \
    analytics-service
  do
    echo "============================================================"
    echo "SERVIÇO: $svc"
    echo "============================================================"

    awk "/SERVIÇO: $svc/,/SERVIÇO:/" "$INPUT_LOG" || true

    echo
  done

} > "$OUTPUT_MD"

echo
echo "Arquivo consolidado:"
echo "$OUTPUT_MD"

echo
echo "============================================================"
echo "BLOCO 9 FINALIZADO"
echo "============================================================"
