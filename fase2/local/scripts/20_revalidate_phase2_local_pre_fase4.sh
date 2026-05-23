#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

echo "============================================================"
echo "BLOCO 20 - REVALIDAR FASE 2 LOCAL CONSOLIDADA"
echo "============================================================"
echo "Data: $(date)"
echo

ROOT="$HOME/togglemaster-tc"
PHASE="$ROOT/fase2"
LOG="$PHASE/logs/fase2-bloco20-revalidacao-local-pre-fase4.log"
EVID="$PHASE/docs/evidencias/fase2-bloco20-revalidacao-local-pre-fase4.md"
TMP="$PHASE/tmp/bloco20"

mkdir -p "$PHASE/logs" "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<EOM
# Fase 2 - BLOCO 20 - Revalidação Local Pré-Fase 4

Data: $(date)

## Objetivo

Revalidar que a Fase 2 local continua funcional antes de qualquer avanço para a Fase 4.

Este bloco valida a cadeia consolidada local da Fase 2:

- estabilização runtime local;
- 5 microsserviços;
- Redis;
- LocalStack;
- SQS local;
- DynamoDB local;
- fluxo E2E local.

Este bloco não altera AWS, Terraform, EKS, ArgoCD ou recursos cloud.

EOM

section() {
  echo
  echo "============================================================"
  echo "$1"
  echo "============================================================"
  echo
  {
    echo
    echo "## $1"
    echo
  } >> "$EVID"
}

record_cmd() {
  local title="$1"
  shift

  echo
  echo "### $title"
  echo "\$ $*"
  echo

  {
    echo
    echo "### $title"
    echo
    echo '```bash'
    echo "\$ $*"
  } >> "$EVID"

  set +e
  "$@" 2>&1 | tee "$TMP/last.out"
  local rc=${PIPESTATUS[0]}
  set -e

  cat "$TMP/last.out" >> "$EVID"

  {
    echo
    echo '```'
    echo
    echo "RC: \`$rc\`"
  } >> "$EVID"

  echo
  echo "RC=$rc"
  return "$rc"
}

section "1. Pré-checks locais"

record_cmd "Diretório raiz" pwd
record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -5
record_cmd "Docker version" docker --version
record_cmd "Docker compose version" docker compose version

section "2. Conferir scripts consolidados da Fase 2"

S16="$PHASE/local/scripts/16_stabilize_phase2_runtime.sh"
S17="$PHASE/local/scripts/17_validate_phase2_e2e_flow.sh"

for s in "$S16" "$S17"; do
  if [ ! -f "$s" ]; then
    echo "ERRO: script obrigatório não encontrado: $s"
    echo "- ERRO: script obrigatório não encontrado: \`$s\`" >> "$EVID"
    exit 20
  fi

  chmod +x "$s"
  bash -n "$s"
  echo "OK: script encontrado e sintaticamente válido: $s"
  echo "- OK: \`$s\` encontrado e sintaticamente válido." >> "$EVID"
done

section "3. Executar estabilização local da Fase 2"

set +e
bash "$S16"
S16_RC=$?
set -e

echo
echo "S16_RC=$S16_RC"
echo "- Resultado script 16: \`$S16_RC\`" >> "$EVID"

if [ "$S16_RC" -ne 0 ]; then
  echo "ERRO: script 16 falhou. Não vou seguir para o E2E."
  echo "- ERRO: script 16 falhou. Revalidação interrompida antes do E2E." >> "$EVID"
  exit "$S16_RC"
fi

section "4. Executar E2E local da Fase 2"

set +e
bash "$S17"
S17_RC=$?
set -e

echo
echo "S17_RC=$S17_RC"
echo "- Resultado script 17: \`$S17_RC\`" >> "$EVID"

if [ "$S17_RC" -ne 0 ]; then
  echo "ERRO: script 17 falhou. Fase 2 local não está validada."
  echo "- ERRO: script 17 falhou. Fase 2 local não está validada." >> "$EVID"
  exit "$S17_RC"
fi

section "5. Coletar resumo pós-validação"

record_cmd "Containers relacionados à Fase 2" docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo
echo "Buscando evidência final do BLOCO 17, se existir..."
find "$PHASE/docs/evidencias" -maxdepth 1 -type f \
  \( -name '*bloco17*' -o -name '*fase2*e2e*' \) \
  -printf '%TY-%Tm-%Td %TH:%TM %p\n' \
  | sort \
  | tail -10 \
  | tee "$TMP/evidencias-fase2-recentes.txt"

{
  echo
  echo "### Evidências recentes relacionadas ao E2E Fase 2"
  echo
  echo '```text'
  cat "$TMP/evidencias-fase2-recentes.txt"
  echo
  echo '```'
} >> "$EVID"

section "6. Resultado"

{
  echo
  echo "## Resultado"
  echo
  echo "- Script 16: \`$S16_RC\`"
  echo "- Script 17: \`$S17_RC\`"
  echo "- Log completo: \`$LOG\`"
} >> "$EVID"

echo
echo "============================================================"
echo "BLOCO 20 CONCLUÍDO COM SUCESSO"
echo "Fase 2 local revalidada pré-Fase 4."
echo "S16_RC=$S16_RC"
echo "S17_RC=$S17_RC"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "============================================================"

exit 0
