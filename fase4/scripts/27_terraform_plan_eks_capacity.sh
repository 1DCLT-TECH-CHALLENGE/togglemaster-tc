#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks.md"
LOG="$PHASE/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks.log"
TMP="$PHASE/tmp/bloco27"

TF_ENV="fase3/terraform/environments/dev"
PLAN_FILE="$TMP/tfplan-capacity-fase4.bin"
PLAN_TEXT="$TMP/tfplan-capacity-fase4.txt"
PLAN_REDACTED="$TMP/tfplan-capacity-fase4-redacted.txt"

AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"

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

redact_file() {
  local src="$1"
  local dst="$2"

  sed -E \
    -e 's/tm_key_[A-Za-z0-9]{20,}/tm_key_REDACTED/g' \
    -e 's/AKIA[0-9A-Z]{16}/AWS_ACCESS_KEY_ID_REDACTED/g' \
    -e 's/ASIA[0-9A-Z]{16}/AWS_ACCESS_KEY_ID_REDACTED/g' \
    -e 's/(aws_secret_access_key|AWS_SECRET_ACCESS_KEY)([[:space:]]*=[[:space:]]*)"?[^"[:space:]]+"?/\1\2REDACTED/Ig' \
    -e 's/(aws_session_token|AWS_SESSION_TOKEN)([[:space:]]*=[[:space:]]*)"?[^"[:space:]]+"?/\1\2REDACTED/Ig' \
    "$src" > "$dst"
}

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 27 - Terraform Plan da Correção de Capacidade do EKS

Data: $(date)

## Objetivo

Gerar e revisar o \`terraform plan\` da correção de capacidade do EKS antes de qualquer \`terraform apply\`.

Este bloco:

- executa \`terraform plan -detailed-exitcode\`;
- salva o plano binário apenas em diretório temporário não versionado;
- registra saída textual redigida;
- não executa \`terraform apply\`;
- não altera recursos AWS.

EOM

echo "============================================================"
echo "FASE 4 - BLOCO 27 - TERRAFORM PLAN CAPACIDADE EKS"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado Git inicial"

record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -8

allowed_bloco27_status_filter() {
  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks\.md$|^\?\? fase4/scripts/27_terraform_plan_eks_capacity\.sh$|^\?\? fase4/scripts/$' || true
}

UNEXPECTED_STATUS="$(git status --short | allowed_bloco27_status_filter)"
if [ -n "$UNEXPECTED_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do BLOCO 27:"
  echo "$UNEXPECTED_STATUS"
  echo "- ERRO: Git tem alterações inesperadas no início do BLOCO 27." >> "$EVID"
  exit 10
fi

echo "OK: Git limpo, exceto artefatos esperados do próprio BLOCO 27."
echo "- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 27." >> "$EVID"

section "2. Pré-checks AWS/Terraform"

export AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION"

record_cmd "AWS identity" aws sts get-caller-identity --output table
record_cmd "Terraform version" terraform version
record_cmd "Terraform init" terraform -chdir="$TF_ENV" init
record_cmd "Terraform validate" terraform -chdir="$TF_ENV" validate

section "3. Confirmar IaC desejado"

record_cmd "Valores EKS em main.tf" bash -lc "grep -nE 'module \"eks\"|node_instance_types|node_min_size|node_desired_size|node_max_size' fase3/terraform/environments/dev/main.tf"
record_cmd "Nodegroup atual na AWS" aws eks describe-nodegroup \
  --cluster-name togglemaster-dev-eks \
  --nodegroup-name togglemaster-dev-default-ng \
  --region "$AWS_REGION" \
  --query 'nodegroup.{nodegroupName:nodegroupName,status:status,instanceTypes:instanceTypes,scalingConfig:scalingConfig}' \
  --output table

section "4. Terraform plan"

set +e
terraform -chdir="$TF_ENV" plan -detailed-exitcode -out="$PWD/$PLAN_FILE" -no-color 2>&1 | tee "$PLAN_TEXT"
PLAN_RC=${PIPESTATUS[0]}
set -e

redact_file "$PLAN_TEXT" "$PLAN_REDACTED"

echo
echo "PLAN_RC=$PLAN_RC"

{
  echo
  echo "### Terraform plan redigido"
  echo
  echo '```text'
  cat "$PLAN_REDACTED"
  echo
  echo '```'
  echo
  echo "PLAN_RC: \`$PLAN_RC\`"
} >> "$EVID"

if [ "$PLAN_RC" -eq 0 ]; then
  echo "ERRO: Terraform plan retornou 0, sem mudanças. Esperávamos mudança de capacidade no node group."
  echo "- ERRO: plan sem mudanças, inesperado para este bloco." >> "$EVID"
  exit 20
fi

if [ "$PLAN_RC" -ne 2 ]; then
  echo "ERRO: Terraform plan falhou com código inesperado: $PLAN_RC"
  echo "- ERRO: terraform plan falhou com código \`$PLAN_RC\`." >> "$EVID"
  exit "$PLAN_RC"
fi

section "5. Análise automática do plano"

python3 - <<'PY' "$PLAN_REDACTED" | tee "$TMP/plan-analysis.txt"
from pathlib import Path
import re
import sys

plan = Path(sys.argv[1]).read_text(errors="ignore")

# O Terraform plan contém uma fase de "Refreshing state" com todos os recursos.
# A análise deve considerar apenas o bloco de ações planejadas.
actions_start_marker = "Terraform will perform the following actions:"
summary_marker = "Plan:"

if actions_start_marker not in plan:
    print("PLAN_REVIEW=BLOCK_ACTIONS_SECTION_NOT_FOUND")
    sys.exit(30)

actions_section = plan.split(actions_start_marker, 1)[1]

summary_match = re.search(r"Plan:\s*(\d+)\s+to add,\s*(\d+)\s+to change,\s*(\d+)\s+to destroy\.", plan)
if not summary_match:
    print("PLAN_REVIEW=BLOCK_PLAN_SUMMARY_NOT_FOUND")
    sys.exit(31)

adds, changes, destroys = map(int, summary_match.groups())

checks = {
    "plan_adds": adds,
    "plan_changes": changes,
    "plan_destroys": destroys,
    "actions_mentions_eks_node_group": "module.eks.aws_eks_node_group.default" in actions_section,
    "actions_update_in_place": "~ resource \"aws_eks_node_group\" \"default\"" in actions_section or "~ update in-place" in plan,
    "actions_desired_2_to_5": bool(re.search(r"desired_size\s*=\s*2\s*->\s*5", actions_section)),
    "actions_max_3_to_5": bool(re.search(r"max_size\s*=\s*3\s*->\s*5", actions_section)),
    "actions_min_1_to_2": bool(re.search(r"min_size\s*=\s*1\s*->\s*2", actions_section)),
    "actions_replacement": "must be replaced" in actions_section.lower(),
    "actions_destroy_resource": "will be destroyed" in actions_section.lower() or re.search(r"^\s*-\s+resource\s+", actions_section, re.MULTILINE) is not None,
    "actions_unexpected_rds": "aws_db_instance" in actions_section,
    "actions_unexpected_vpc": "aws_vpc" in actions_section or "aws_subnet" in actions_section,
    "actions_unexpected_ecr": "aws_ecr" in actions_section,
}

for k, v in checks.items():
    print(f"{k}={v}")

if adds != 0 or changes != 1 or destroys != 0:
    print("PLAN_REVIEW=BLOCK_UNEXPECTED_PLAN_SUMMARY")
    sys.exit(32)

if not checks["actions_mentions_eks_node_group"]:
    print("PLAN_REVIEW=BLOCK_EKS_NODEGROUP_ACTION_NOT_FOUND")
    sys.exit(33)

if not checks["actions_update_in_place"]:
    print("PLAN_REVIEW=BLOCK_NOT_UPDATE_IN_PLACE")
    sys.exit(34)

if not (checks["actions_desired_2_to_5"] and checks["actions_max_3_to_5"] and checks["actions_min_1_to_2"]):
    print("PLAN_REVIEW=BLOCK_SCALING_CHANGE_NOT_MATCHED")
    sys.exit(35)

if checks["actions_replacement"] or checks["actions_destroy_resource"]:
    print("PLAN_REVIEW=BLOCK_REPLACEMENT_OR_DESTROY_IN_ACTIONS")
    sys.exit(36)

if checks["actions_unexpected_rds"] or checks["actions_unexpected_vpc"] or checks["actions_unexpected_ecr"]:
    print("PLAN_REVIEW=BLOCK_UNEXPECTED_RESOURCE_SCOPE_IN_ACTIONS")
    sys.exit(37)

print("PLAN_REVIEW=PASS_AUTOMATED_REVIEW")
PY

ANALYSIS_RC=${PIPESTATUS[0]}

{
  echo
  echo "### Análise automática do plano"
  echo
  echo '```text'
  cat "$TMP/plan-analysis.txt"
  echo
  echo '```'
  echo
  echo "ANALYSIS_RC: \`$ANALYSIS_RC\`"
} >> "$EVID"

if [ "$ANALYSIS_RC" -ne 0 ]; then
  echo "ERRO: análise automática bloqueou o plano."
  exit "$ANALYSIS_RC"
fi

section "6. Segurança"

record_cmd "Check tfstate/tfvars versionados" bash -lc "git ls-files | grep -E '(^|/).*\\.tfstate(\\.backup)?$|(^|/)terraform\\.tfvars$|\\.auto\\.tfvars$' || true"

TRACKED_STATE_FILES="$(git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true)"
if [ -n "$TRACKED_STATE_FILES" ]; then
  echo "ERRO: arquivos state/tfvars versionados:"
  echo "$TRACKED_STATE_FILES"
  exit 40
fi

cat >> "$EVID" <<'EOF'

## Segurança

O plano binário foi salvo em diretório temporário não versionado e não deve ser commitado.

Nenhum `tfstate`, `terraform.tfvars` real ou `*.auto.tfvars` está versionado.

EOF

section "7. Resultado"

cat >> "$EVID" <<EOF

## Resultado

BLOCO 27 concluído com sucesso.

- \`PLAN_RC=$PLAN_RC\`
- Análise automática: \`PASS_AUTOMATED_REVIEW\`
- Nenhum \`terraform apply\` foi executado.

Próximo bloco recomendado:

1. revisar a evidência do plano;
2. executar \`terraform apply\` em bloco separado;
3. validar EKS/nodegroup após apply;
4. reexecutar gate de capacidade.

EOF

echo
echo "============================================================"
echo "BLOCO 27 FINALIZADO"
echo "PLAN_RC=$PLAN_RC"
echo "Plano gerado e analisado. Nenhum apply foi executado."
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
