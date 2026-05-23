#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md"
LOG="$PHASE/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.log"
TMP="$PHASE/tmp/bloco28"

TF_ENV="fase3/terraform/environments/dev"
PLAN_FILE="$TMP/tfplan-capacity-fase4-apply.bin"
PLAN_TEXT="$TMP/tfplan-capacity-fase4-apply.txt"
PLAN_REDACTED="$TMP/tfplan-capacity-fase4-apply-redacted.txt"
APPLY_TEXT="$TMP/tfapply-capacity-fase4.txt"
APPLY_REDACTED="$TMP/tfapply-capacity-fase4-redacted.txt"
CAPACITY_REPORT="$TMP/capacity-after-apply.txt"

AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
CLUSTER_NAME="togglemaster-dev-eks"
NODEGROUP_NAME="togglemaster-dev-default-ng"

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
# Fase 4 - BLOCO 28 - Terraform Apply da Correção de Capacidade do EKS

Data: $(date)

## Objetivo

Executar a correção de capacidade do EKS para permitir a instalação segura da stack de observabilidade da Fase 4.

Este bloco:

- gera novo \`terraform plan\` antes do apply;
- valida automaticamente que o plano altera somente o node group EKS;
- executa \`terraform apply\`;
- aguarda node group \`ACTIVE\`;
- aguarda 5 nodes \`Ready\`;
- executa capacity check pós-apply;
- não instala Prometheus, Grafana, Loki ou OTel.

EOM

echo "============================================================"
echo "FASE 4 - BLOCO 28 - TERRAFORM APPLY CAPACIDADE EKS"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado Git inicial"

record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -8

allowed_bloco28_status_filter() {
  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks\.md$|^\?\? fase4/scripts/28_terraform_apply_eks_capacity\.sh$|^\?\? fase4/scripts/$' || true
}

UNEXPECTED_STATUS="$(git status --short | allowed_bloco28_status_filter)"
if [ -n "$UNEXPECTED_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do BLOCO 28:"
  echo "$UNEXPECTED_STATUS"
  echo "- ERRO: Git tem alterações inesperadas no início do BLOCO 28." >> "$EVID"
  exit 10
fi

echo "OK: Git limpo, exceto artefatos esperados do próprio BLOCO 28."
echo "- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 28." >> "$EVID"

section "2. Pré-checks AWS/Terraform"

export AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION"

record_cmd "AWS identity" aws sts get-caller-identity --output table
record_cmd "Terraform init" terraform -chdir="$TF_ENV" init
record_cmd "Terraform validate" terraform -chdir="$TF_ENV" validate
record_cmd "Nodegroup antes do apply" aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --region "$AWS_REGION" \
  --query 'nodegroup.{nodegroupName:nodegroupName,status:status,instanceTypes:instanceTypes,scalingConfig:scalingConfig}' \
  --output table
record_cmd "Nodes antes do apply" kubectl get nodes -o wide

section "3. Novo Terraform plan pré-apply"

set +e
terraform -chdir="$TF_ENV" plan -detailed-exitcode -out="$PWD/$PLAN_FILE" -no-color 2>&1 | tee "$PLAN_TEXT"
PLAN_RC=${PIPESTATUS[0]}
set -e

redact_file "$PLAN_TEXT" "$PLAN_REDACTED"

echo
echo "PLAN_RC=$PLAN_RC"

{
  echo
  echo "### Terraform plan redigido pré-apply"
  echo
  echo '```text'
  cat "$PLAN_REDACTED"
  echo
  echo '```'
  echo
  echo "PLAN_RC: \`$PLAN_RC\`"
} >> "$EVID"

if [ "$PLAN_RC" -ne 2 ]; then
  echo "ERRO: plan pré-apply deveria retornar 2. Retornou: $PLAN_RC"
  echo "- ERRO: plan pré-apply retornou \`$PLAN_RC\`, esperado \`2\`." >> "$EVID"
  exit 20
fi

section "4. Revisão automática do plano pré-apply"

python3 - <<'PY' "$PLAN_REDACTED" | tee "$TMP/plan-analysis.txt"
from pathlib import Path
import re
import sys

plan = Path(sys.argv[1]).read_text(errors="ignore")

actions_marker = "Terraform will perform the following actions:"
if actions_marker not in plan:
    print("PLAN_REVIEW=BLOCK_ACTIONS_SECTION_NOT_FOUND")
    sys.exit(30)

actions_section = plan.split(actions_marker, 1)[1]

summary = re.search(r"Plan:\s*(\d+)\s+to add,\s*(\d+)\s+to change,\s*(\d+)\s+to destroy\.", plan)
if not summary:
    print("PLAN_REVIEW=BLOCK_PLAN_SUMMARY_NOT_FOUND")
    sys.exit(31)

adds, changes, destroys = map(int, summary.groups())

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
  echo "### Revisão automática do plano"
  echo
  echo '```text'
  cat "$TMP/plan-analysis.txt"
  echo
  echo '```'
  echo
  echo "ANALYSIS_RC: \`$ANALYSIS_RC\`"
} >> "$EVID"

if [ "$ANALYSIS_RC" -ne 0 ]; then
  echo "ERRO: revisão automática bloqueou o apply."
  exit "$ANALYSIS_RC"
fi

section "5. Terraform apply"

set +e
terraform -chdir="$TF_ENV" apply -no-color "$PWD/$PLAN_FILE" 2>&1 | tee "$APPLY_TEXT"
APPLY_RC=${PIPESTATUS[0]}
set -e

redact_file "$APPLY_TEXT" "$APPLY_REDACTED"

echo
echo "APPLY_RC=$APPLY_RC"

{
  echo
  echo "### Terraform apply redigido"
  echo
  echo '```text'
  cat "$APPLY_REDACTED"
  echo
  echo '```'
  echo
  echo "APPLY_RC: \`$APPLY_RC\`"
} >> "$EVID"

if [ "$APPLY_RC" -ne 0 ]; then
  echo "ERRO: terraform apply falhou."
  exit "$APPLY_RC"
fi

section "6. Aguardar node group ACTIVE"

set +e
aws eks wait nodegroup-active \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --region "$AWS_REGION"
WAIT_NG_RC=$?
set -e

echo "WAIT_NG_RC=$WAIT_NG_RC"

{
  echo
  echo "### Wait nodegroup active"
  echo
  echo "- WAIT_NG_RC: \`$WAIT_NG_RC\`"
} >> "$EVID"

if [ "$WAIT_NG_RC" -ne 0 ]; then
  echo "ERRO: node group não ficou ACTIVE no waiter da AWS."
  exit "$WAIT_NG_RC"
fi

record_cmd "Nodegroup após apply" aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --region "$AWS_REGION" \
  --query 'nodegroup.{nodegroupName:nodegroupName,status:status,instanceTypes:instanceTypes,scalingConfig:scalingConfig}' \
  --output table

section "7. Aguardar 5 nodes Ready"

READY_NODES=0
TOTAL_NODES=0

for attempt in $(seq 1 60); do
  echo "Tentativa $attempt/60 - conferindo nodes Ready..."
  kubectl get nodes -o wide || true

  TOTAL_NODES="$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"
  READY_NODES="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 == "Ready" {count++} END {print count+0}')"

  echo "TOTAL_NODES=$TOTAL_NODES"
  echo "READY_NODES=$READY_NODES"

  if [ "$TOTAL_NODES" -ge 5 ] && [ "$READY_NODES" -ge 5 ]; then
    break
  fi

  sleep 20
done

{
  echo
  echo "### Nodes após aguardar escala"
  echo
  echo '```text'
  kubectl get nodes -o wide
  echo
  echo '```'
  echo
  echo "- TOTAL_NODES: \`$TOTAL_NODES\`"
  echo "- READY_NODES: \`$READY_NODES\`"
} >> "$EVID"

if [ "$TOTAL_NODES" -lt 5 ] || [ "$READY_NODES" -lt 5 ]; then
  echo "ERRO: cluster não atingiu 5 nodes Ready."
  exit 50
fi

section "8. Capacity check pós-apply"

kubectl get nodes -o json > "$TMP/nodes-after.json"
kubectl get pods -A -o json > "$TMP/pods-after.json"

python3 - <<'PY' | tee "$CAPACITY_REPORT"
import json
from pathlib import Path
from collections import defaultdict

nodes = json.loads(Path("fase4/tmp/bloco28/nodes-after.json").read_text())
pods = json.loads(Path("fase4/tmp/bloco28/pods-after.json").read_text())

node_capacity = {}
node_cpu = {}
node_mem = {}

for n in nodes.get("items", []):
    name = n["metadata"]["name"]
    alloc = n.get("status", {}).get("allocatable", {})
    node_capacity[name] = int(alloc.get("pods", "0"))
    node_cpu[name] = alloc.get("cpu", "unknown")
    node_mem[name] = alloc.get("memory", "unknown")

pods_by_node = defaultdict(list)
pods_by_ns = defaultdict(int)

for p in pods.get("items", []):
    ns = p["metadata"].get("namespace", "unknown")
    node = p.get("spec", {}).get("nodeName")
    pods_by_ns[ns] += 1
    if node:
        pods_by_node[node].append(p)

total_capacity = sum(node_capacity.values())
total_used = sum(len(pods_by_node[n]) for n in node_capacity)
total_remaining = total_capacity - total_used

print("Resumo por node:")
for node in sorted(node_capacity):
    used = len(pods_by_node[node])
    remaining = node_capacity[node] - used
    print(f"- {node}")
    print(f"  allocatable.cpu={node_cpu[node]}")
    print(f"  allocatable.memory={node_mem[node]}")
    print(f"  pod.capacity={node_capacity[node]}")
    print(f"  pod.used={used}")
    print(f"  pod.remaining={remaining}")

print()
print("Resumo por namespace:")
for ns, count in sorted(pods_by_ns.items()):
    print(f"- {ns}: {count} pods")

print()
print(f"TOTAL_POD_CAPACITY={total_capacity}")
print(f"TOTAL_PODS_USED={total_used}")
print(f"TOTAL_PODS_REMAINING={total_remaining}")

# Reusa a mesma exigência do BLOCO 24.
required_total_free = 14
print(f"REQUIRED_TOTAL_FREE_PODS={required_total_free}")

if total_remaining >= required_total_free:
    print("CAPACITY_GATE=PASS")
else:
    print("CAPACITY_GATE=FAIL")
PY

cat "$CAPACITY_REPORT"

{
  echo
  echo "### Capacity check pós-apply"
  echo
  echo '```text'
  cat "$CAPACITY_REPORT"
  echo
  echo '```'
} >> "$EVID"

CAPACITY_GATE="$(grep '^CAPACITY_GATE=' "$CAPACITY_REPORT" | tail -1 | cut -d= -f2 || true)"

if [ "$CAPACITY_GATE" != "PASS" ]; then
  echo "ERRO: capacity gate pós-apply não passou."
  exit 60
fi

section "9. Estado final"

record_cmd "Pods finais" kubectl get pods -A -o wide
record_cmd "ArgoCD application final" kubectl get application togglemaster-dev -n argocd -o wide
record_cmd "Git status final do script" git status --short
record_cmd "Check tfstate/tfvars/plan versionados" bash -lc "git ls-files | grep -E '(^|/).*\\.tfstate(\\.backup)?$|(^|/)terraform\\.tfvars$|\\.auto\\.tfvars$|(^|/).*tfplan.*|(^|/).*\\.bin$' || true"

TRACKED_SENSITIVE_FILES="$(git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$|(^|/).*tfplan.*|(^|/).*\.bin$' || true)"
if [ -n "$TRACKED_SENSITIVE_FILES" ]; then
  echo "ERRO: state/tfvars/plan binário versionado detectado."
  echo "$TRACKED_SENSITIVE_FILES"
  exit 70
fi

section "10. Resultado"

cat >> "$EVID" <<EOF

## Resultado

BLOCO 28 concluído com sucesso.

- \`PLAN_RC=$PLAN_RC\`
- \`PLAN_REVIEW=PASS_AUTOMATED_REVIEW\`
- \`APPLY_RC=$APPLY_RC\`
- \`WAIT_NG_RC=$WAIT_NG_RC\`
- \`TOTAL_NODES=$TOTAL_NODES\`
- \`READY_NODES=$READY_NODES\`
- \`CAPACITY_GATE=$CAPACITY_GATE\`

Nenhuma stack de observabilidade foi instalada neste bloco.

Próximo passo recomendado:

1. versionar esta evidência;
2. iniciar preparação GitOps/Helm da stack base de observabilidade;
3. instalar Prometheus/Grafana/Loki/OTel em blocos controlados.

EOF

echo
echo "============================================================"
echo "BLOCO 28 FINALIZADO"
echo "PLAN_RC=$PLAN_RC"
echo "APPLY_RC=$APPLY_RC"
echo "WAIT_NG_RC=$WAIT_NG_RC"
echo "TOTAL_NODES=$TOTAL_NODES"
echo "READY_NODES=$READY_NODES"
echo "CAPACITY_GATE=$CAPACITY_GATE"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
