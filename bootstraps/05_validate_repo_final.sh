#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
cd "$ROOT"

section "ToggleMaster TC - Validação final do repositório"

echo "1. Git status"
git status --short
echo

echo "2. Últimos commits"
git log --oneline --decorate -10
echo

echo "3. Arquivos proibidos/gerados"
BAD_FILES="$(find . -type f \( \
  -name "*.tfstate" -o \
  -name "*.tfstate.*" -o \
  -name "*.tfvars" -o \
  -name "*.auto.tfvars" -o \
  -name "*.tfplan" -o \
  -name "tfplan-destroy" -o \
  -name "*.mp4" -o \
  -name "*.mov" \
  \) -not -path "./.git/*" -print | sort)"

if [ -n "$BAD_FILES" ]; then
  echo "$BAD_FILES"
  fail "Arquivos proibidos/gerados encontrados."
else
  echo "OK: nenhum arquivo proibido conhecido encontrado."
fi
echo

echo "4. Sintaxe dos bootstraps"
for f in bootstraps/*.sh bootstraps/lib/*.sh; do
  bash -n "$f"
done
echo "OK: sintaxe shell válida."
echo

echo "5. Arquivos grandes"
find . -type f \
  -not -path "./.git/*" \
  -printf "%s %p\n" \
  | sort -nr \
  | head -20 \
  | awk '{printf "%.2f MB  %s\n", $1/1024/1024, $2}'
echo

echo "6. Terraform offline"
cd "$ROOT/fase3/terraform/environments/dev"
terraform init -backend=false
terraform fmt -recursive -check "$ROOT/fase3/terraform"
terraform validate
cd "$ROOT"
echo

echo "7. Render GitOps"
if command -v kubectl >/dev/null 2>&1; then
  kubectl kustomize fase3/gitops/overlays/dev >/tmp/togglemaster-fase3-render.yaml
  kubectl kustomize fase4/gitops/apps/observability >/tmp/togglemaster-fase4-apps-render.yaml
  echo "OK: render GitOps concluído."
else
  warn "kubectl não encontrado; render ignorado."
fi

section "Validação final concluída"
