#!/usr/bin/env bash
set -Eeuo pipefail

BASE="${BASE:-$HOME/togglemaster-tc}"
FASE3="$BASE/fase3"

echo "============================================================"
echo "BOOTSTRAP FASE 3 - OFFLINE / LOCAL"
echo "============================================================"
echo "Data: $(date)"
echo

cd "$BASE"

echo "[1/6] Conferindo estrutura raiz"
for dir in bootstraps _shared fase1 fase2 fase3 fase4; do
  if [[ -d "$BASE/$dir" ]]; then
    echo "OK: $dir"
  else
    echo "ERRO: diretório obrigatório ausente: $BASE/$dir"
    exit 1
  fi
done

echo
echo "[2/6] Conferindo que a Fase 3 não vai recriar responsabilidades da Fase 2"
if [[ -f "$BASE/fase2/docs/evidencias/fase2-fechamento-local.md" ]]; then
  echo "OK: evidência de fechamento da Fase 2 encontrada."
else
  echo "AVISO: evidência de fechamento da Fase 2 não encontrada."
  echo "A Fase 3 offline pode validar IaC/GitOps, mas a base da Fase 2 deve estar versionada/validada."
fi

echo
echo "[3/6] Conferindo guardrails AWS"
if env | grep -E '^AWS_(ACCESS_KEY_ID|SECRET_ACCESS_KEY|SESSION_TOKEN)=' >/dev/null 2>&1; then
  echo "AVISO: variáveis AWS detectadas no ambiente."
  echo "Este bootstrap offline NÃO usa credenciais AWS."
else
  echo "OK: nenhuma variável AWS detectada."
fi

echo
echo "[4/6] Conferindo comandos executáveis proibidos neste bootstrap"

FORBIDDEN_RUNTIME_COMMANDS="$(
  awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*echo[[:space:]]/ { next }
    /FORBIDDEN_RUNTIME_COMMANDS/ { next }
    /awk / { next }
    /grep / { next }

    /^[[:space:]]*terraform[[:space:]]+(plan|apply)([[:space:]]|$)/ { print }
    /^[[:space:]]*aws[[:space:]]+configure([[:space:]]|$)/ { print }
    /^[[:space:]]*aws[[:space:]]+sts[[:space:]]+get-caller-identity([[:space:]]|$)/ { print }
    /^[[:space:]]*kubectl[[:space:]]+apply([[:space:]]|$)/ { print }
    /^[[:space:]]*helm[[:space:]]+install([[:space:]]|$)/ { print }
  ' "$0"
)"

if [[ -n "$FORBIDDEN_RUNTIME_COMMANDS" ]]; then
  echo "ERRO: bootstrap offline contém comando executável proibido:"
  echo "$FORBIDDEN_RUNTIME_COMMANDS"
  exit 1
else
  echo "OK: bootstrap offline não contém comandos executáveis proibidos."
fi

echo
echo "[5/6] Executando validação offline oficial da Fase 3"
"$FASE3/local/scripts/01_validate_phase3_offline.sh"

echo
echo "[6/6] Resumo"
echo "Fase 3 offline validada."
echo
echo "Não foi executado:"
echo "- aws configure"
echo "- aws sts get-caller-identity"
echo "- terraform plan"
echo "- terraform apply"
echo "- kubectl apply"
echo "- helm install"
echo "- criação de recurso AWS"
echo "- login no AWS Academy"

echo
echo "============================================================"
echo "BOOTSTRAP FASE 3 OFFLINE FINALIZADO COM SUCESSO"
echo "============================================================"
