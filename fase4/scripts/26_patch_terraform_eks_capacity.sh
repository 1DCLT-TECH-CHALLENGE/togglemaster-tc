#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco26-iac-capacidade-eks.md"
LOG="$PHASE/docs/evidencias/fase4-bloco26-iac-capacidade-eks.log"
TMP="$PHASE/tmp/bloco26"

TF_ROOT="fase3/terraform"
TF_ENV="fase3/terraform/environments/dev"
TF_MAIN="$TF_ENV/main.tf"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

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

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 26 - Alteração IaC de Capacidade do EKS

Data: $(date)

## Objetivo

Alterar o Terraform do ambiente dev para ampliar a capacidade do EKS antes da instalação da stack de observabilidade da Fase 4.

Este bloco:

- altera código IaC versionado;
- executa \`terraform fmt\`;
- executa \`terraform init -backend=false\`;
- executa \`terraform validate\`;
- não executa \`terraform plan\`;
- não executa \`terraform apply\`;
- não altera recursos AWS nesta etapa.

EOM

echo "============================================================"
echo "FASE 4 - BLOCO 26 - PATCH TERRAFORM CAPACIDADE EKS"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado Git inicial"

record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -8

allowed_bloco26_status_filter() {
  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco26-iac-capacidade-eks\.md$|^\?\? fase4/scripts/26_patch_terraform_eks_capacity\.sh$|^\?\? fase4/scripts/$' || true
}

UNEXPECTED_STATUS="$(git status --short | allowed_bloco26_status_filter)"
if [ -n "$UNEXPECTED_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do BLOCO 26:"
  echo "$UNEXPECTED_STATUS"
  echo "- ERRO: Git tem alterações inesperadas no início do BLOCO 26." >> "$EVID"
  exit 10
fi

echo "OK: Git limpo, exceto artefatos esperados do próprio BLOCO 26."
echo "- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 26." >> "$EVID"

section "2. Pré-checks Terraform"

record_cmd "Terraform version" terraform version
record_cmd "Arquivos Terraform relevantes" bash -lc "find fase3/terraform/modules/eks fase3/terraform/environments/dev -maxdepth 2 -type f \\( -name '*.tf' -o -name '*.tfvars.example' \\) | sort"
record_cmd "Check tfstate/tfvars versionados" bash -lc "git ls-files | grep -E '(^|/).*\\.tfstate(\\.backup)?$|(^|/)terraform\\.tfvars$|\\.auto\\.tfvars$' || true"

TRACKED_STATE_FILES="$(git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true)"
if [ -n "$TRACKED_STATE_FILES" ]; then
  echo "ERRO: arquivos de state/tfvars reais estão versionados:"
  echo "$TRACKED_STATE_FILES"
  exit 20
fi

echo "OK: nenhum tfstate/tfvars real está versionado."
echo "- OK: nenhum tfstate/tfvars real está versionado." >> "$EVID"

section "3. Backup local e patch seguro do main.tf"

test -f "$TF_MAIN"
cp "$TF_MAIN" "$TMP/main.tf.before"

python3 - <<'PY'
from pathlib import Path
import re
import sys

path = Path("fase3/terraform/environments/dev/main.tf")
text = path.read_text()

module_match = re.search(r'module\s+"eks"\s*\{', text)
if not module_match:
    print("ERRO: bloco module \"eks\" não encontrado em fase3/terraform/environments/dev/main.tf")
    sys.exit(30)

start = module_match.start()
brace_start = text.find("{", module_match.end() - 1)
if brace_start == -1:
    print("ERRO: abertura do bloco module \"eks\" não encontrada.")
    sys.exit(31)

depth = 0
end = None
for i in range(brace_start, len(text)):
    ch = text[i]
    if ch == "{":
        depth += 1
    elif ch == "}":
        depth -= 1
        if depth == 0:
            end = i
            break

if end is None:
    print("ERRO: fechamento do bloco module \"eks\" não encontrado.")
    sys.exit(32)

block = text[start:end+1]

settings = {
    "node_instance_types": '["t3.small"]',
    "node_min_size": "2",
    "node_desired_size": "5",
    "node_max_size": "5",
}

def set_hcl_arg(block_text: str, key: str, value: str) -> str:
    pattern = re.compile(rf'^(\s*){re.escape(key)}\s*=\s*.*$', re.MULTILINE)
    replacement = rf'\1{key} = {value}'

    if pattern.search(block_text):
        return pattern.sub(replacement, block_text, count=1)

    # Inserir antes do fechamento do bloco, com indentação de dois espaços.
    closing_index = block_text.rfind("}")
    if closing_index == -1:
        raise RuntimeError(f"Fechamento não encontrado ao inserir {key}")

    insertion = f"  {key} = {value}\n"
    return block_text[:closing_index] + insertion + block_text[closing_index:]

new_block = block
for key, value in settings.items():
    new_block = set_hcl_arg(new_block, key, value)

new_text = text[:start] + new_block + text[end+1:]

if new_text == text:
    print("OK: main.tf já estava com os valores desejados.")
else:
    path.write_text(new_text)
    print("OK: main.tf atualizado com capacidade EKS para Fase 4.")

print("Valores desejados:")
for key, value in settings.items():
    print(f"- {key} = {value}")
PY

cp "$TF_MAIN" "$TMP/main.tf.after"

{
  echo
  echo "### Diff do main.tf"
  echo
  echo '```diff'
  git diff -- "$TF_MAIN"
  echo
  echo '```'
} >> "$EVID"

echo
echo "Diff aplicado:"
git diff -- "$TF_MAIN"

section "4. Terraform fmt/init/validate"

record_cmd "Terraform fmt recursive" terraform -chdir="$TF_ROOT" fmt -recursive
record_cmd "Terraform init backend false" terraform -chdir="$TF_ENV" init -backend=false
record_cmd "Terraform validate" terraform -chdir="$TF_ENV" validate

section "5. Conferência pós-patch"

record_cmd "Valores EKS no main.tf" bash -lc "grep -nE 'module \"eks\"|node_instance_types|node_min_size|node_desired_size|node_max_size' fase3/terraform/environments/dev/main.tf"
record_cmd "Git diff stat" git diff --stat
record_cmd "Git diff Terraform" git diff -- fase3/terraform/environments/dev/main.tf fase3/terraform/modules/eks

section "6. Segurança"

record_cmd "Check final tfstate/tfvars versionados" bash -lc "git ls-files | grep -E '(^|/).*\\.tfstate(\\.backup)?$|(^|/)terraform\\.tfvars$|\\.auto\\.tfvars$' || true"

TRACKED_STATE_FILES_FINAL="$(git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true)"
if [ -n "$TRACKED_STATE_FILES_FINAL" ]; then
  echo "ERRO: arquivos de state/tfvars reais versionados encontrados após patch:"
  echo "$TRACKED_STATE_FILES_FINAL"
  exit 40
fi

cat >> "$EVID" <<'EOF'

## Segurança

Nenhum arquivo `tfstate`, `terraform.tfvars` real ou `*.auto.tfvars` foi versionado neste bloco.

EOF

section "7. Resultado"

cat >> "$EVID" <<'EOF'

## Resultado

BLOCO 26 concluído com sucesso.

A alteração IaC foi preparada e validada localmente.

Próximo bloco recomendado:

1. gerar `terraform plan` em bloco separado;
2. revisar se o plano altera somente o necessário no EKS node group;
3. executar `terraform apply` somente após revisão.

EOF

echo
echo "============================================================"
echo "BLOCO 26 FINALIZADO"
echo "Terraform alterado e validado."
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
