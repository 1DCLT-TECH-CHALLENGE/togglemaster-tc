#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md"
ADR="$PHASE/docs/adr/ADR-003-fase4-correcao-capacidade-observabilidade.md"
LOG="$PHASE/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.log"
TMP="$PHASE/tmp/bloco25"

AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
CLUSTER_NAME="togglemaster-dev-eks"
NODEGROUP_NAME="togglemaster-dev-default-ng"

mkdir -p "$PHASE/docs/evidencias" "$PHASE/docs/adr" "$TMP"

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
# Fase 4 - BLOCO 25 - Plano de Correção de Capacidade para Observabilidade

Data: $(date)

## Objetivo

Planejar a correção definitiva de capacidade do EKS antes da instalação da stack de observabilidade da Fase 4.

Este bloco é read-only do ponto de vista de infraestrutura:

- não executa \`terraform apply\`;
- não altera recursos AWS;
- não instala Prometheus, Grafana, Loki ou OTel;
- apenas calcula opções e registra a decisão técnica.

EOM

echo "============================================================"
echo "FASE 4 - BLOCO 25 - PLANO DE CAPACIDADE"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado Git"

record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -8

allowed_bloco25_status_filter() {
  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade\.md$|^\?\? fase4/docs/adr/ADR-003-fase4-correcao-capacidade-observabilidade\.md$|^\?\? fase4/scripts/25_plan_observability_capacity_fix\.sh$|^\?\? fase4/scripts/$' || true
}

UNEXPECTED_STATUS="$(git status --short | allowed_bloco25_status_filter)"
if [ -n "$UNEXPECTED_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do BLOCO 25:"
  echo "$UNEXPECTED_STATUS"
  echo "- ERRO: Git tem alterações inesperadas no início do BLOCO 25." >> "$EVID"
  exit 10
fi

echo "OK: Git limpo, exceto artefatos esperados do próprio BLOCO 25."
echo "- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 25." >> "$EVID"

section "2. Base confirmada do BLOCO 24"

if [ ! -f "fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md" ]; then
  echo "ERRO: evidência do BLOCO 24 não encontrada."
  exit 20
fi

record_cmd "Resumo do gate de capacidade anterior" bash -lc "grep -E 'CAPACITY_GATE=|TOTAL_PODS_REMAINING=|REQUIRED_TOTAL_FREE_PODS=|RESULT_RC=' fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log 2>/dev/null | tail -30 || true"

section "3. Estado atual read-only do EKS"

export AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION"

record_cmd "AWS identity" aws sts get-caller-identity --output table
record_cmd "EKS nodegroups" aws eks list-nodegroups --cluster-name "$CLUSTER_NAME" --region "$AWS_REGION" --output table
record_cmd "Describe nodegroup atual" aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --region "$AWS_REGION" \
  --query 'nodegroup.{nodegroupName:nodegroupName,status:status,instanceTypes:instanceTypes,scalingConfig:scalingConfig,capacityType:capacityType,amiType:amiType}' \
  --output table
record_cmd "Nodes atuais" kubectl get nodes -o wide
record_cmd "Pods atuais" kubectl get pods -A -o wide

section "4. Inspeção IaC atual"

record_cmd "Terraform EKS variables e module references" bash -lc "grep -RInE --exclude='*.tfstate' --exclude='*.tfstate.backup' --exclude='*.tfvars' --exclude='*.auto.tfvars' 'node_instance_types|node_desired_size|node_min_size|node_max_size|desired_size|min_size|max_size|instance_types' fase3/terraform/modules/eks fase3/terraform/environments/dev || true"

record_cmd "Arquivos Terraform versionados relevantes" bash -lc "find fase3/terraform/modules/eks fase3/terraform/environments/dev -maxdepth 2 -type f \\( -name '*.tf' -o -name '*.tfvars.example' \\) | sort"

record_cmd "Check tfstate/tfvars versionados" bash -lc "git ls-files | grep -E '(^|/).*\\.tfstate(\\.backup)?$|(^|/)terraform\\.tfvars$|\\.auto\\.tfvars$' || true"

TRACKED_STATE_FILES="$(git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true)"
if [ -n "$TRACKED_STATE_FILES" ]; then
  echo "ERRO: existem state/tfvars versionados:"
  echo "$TRACKED_STATE_FILES"
  exit 21
fi

echo "OK: nenhum tfstate/tfvars real versionado."

section "5. Cálculo de opções de capacidade"

kubectl get nodes -o json > "$TMP/nodes.json"
kubectl get pods -A -o json > "$TMP/pods.json"
kubectl get daemonsets -A -o json > "$TMP/daemonsets.json"

python3 - <<'PY' | tee "$TMP/capacity-options.txt"
import json
from pathlib import Path
from collections import defaultdict

nodes = json.loads(Path("fase4/tmp/bloco25/nodes.json").read_text())
pods = json.loads(Path("fase4/tmp/bloco25/pods.json").read_text())
daemonsets = json.loads(Path("fase4/tmp/bloco25/daemonsets.json").read_text())

node_items = nodes.get("items", [])
node_count = len(node_items)

pod_capacity_by_node = {}
for n in node_items:
    name = n["metadata"]["name"]
    alloc = n.get("status", {}).get("allocatable", {})
    pod_capacity_by_node[name] = int(alloc.get("pods", "0"))

if pod_capacity_by_node:
    per_node_pod_capacity = min(pod_capacity_by_node.values())
else:
    per_node_pod_capacity = 0

total_pod_capacity = sum(pod_capacity_by_node.values())

pods_by_node = defaultdict(list)
for p in pods.get("items", []):
    node = p.get("spec", {}).get("nodeName")
    if node:
        pods_by_node[node].append(p)

total_pods_used = sum(len(v) for v in pods_by_node.values())

# Conta daemonsets existentes que rodam por node.
current_daemonsets = []
for ds in daemonsets.get("items", []):
    ns = ds["metadata"].get("namespace", "")
    name = ds["metadata"].get("name", "")
    desired = ds.get("status", {}).get("desiredNumberScheduled", 0)
    if desired > 0:
        current_daemonsets.append((ns, name, desired))

existing_daemonsets_per_node = 0
if node_count:
    # DaemonSets com desired == node_count contam como 1 por node.
    existing_daemonsets_per_node = sum(1 for _, _, desired in current_daemonsets if desired >= node_count)

existing_daemonset_pods = existing_daemonsets_per_node * node_count
existing_non_daemonset_pods = max(total_pods_used - existing_daemonset_pods, 0)

# Estimativa da futura observabilidade.
# Base prevista:
# - node-exporter daemonset
# - promtail ou agente de logs daemonset
# - prometheus-operator
# - prometheus
# - alertmanager
# - grafana
# - kube-state-metrics
# - loki
# - otel-collector
observability_daemonsets_per_node = 2
observability_singleton_pods = 7
buffer_pods = 3

print("Estado atual:")
print(f"- CURRENT_NODE_COUNT={node_count}")
print(f"- CURRENT_PER_NODE_POD_CAPACITY={per_node_pod_capacity}")
print(f"- CURRENT_TOTAL_POD_CAPACITY={total_pod_capacity}")
print(f"- CURRENT_TOTAL_PODS_USED={total_pods_used}")
print(f"- CURRENT_TOTAL_PODS_REMAINING={total_pod_capacity - total_pods_used}")
print(f"- EXISTING_DAEMONSETS_PER_NODE={existing_daemonsets_per_node}")
print(f"- EXISTING_NON_DAEMONSET_PODS={existing_non_daemonset_pods}")

print()
print("DaemonSets existentes detectados:")
for ns, name, desired in current_daemonsets:
    print(f"- {ns}/{name}: desired={desired}")

print()
print("Premissas para observabilidade:")
print(f"- OBSERVABILITY_DAEMONSETS_PER_NODE={observability_daemonsets_per_node}")
print(f"- OBSERVABILITY_SINGLETON_PODS={observability_singleton_pods}")
print(f"- BUFFER_PODS={buffer_pods}")

print()
print("Cenários calculados mantendo o mesmo pod.capacity por node:")
print("nodes,total_capacity,estimated_existing_pods_after_scale,estimated_free_before_observability,required_observability_plus_buffer,estimated_free_after_observability,decision")

recommended = None

for candidate_nodes in range(max(3, node_count), 7):
    total_capacity = candidate_nodes * per_node_pod_capacity
    existing_after_scale = existing_non_daemonset_pods + existing_daemonsets_per_node * candidate_nodes
    free_before_obs = total_capacity - existing_after_scale

    obs_required = (observability_daemonsets_per_node * candidate_nodes) + observability_singleton_pods + buffer_pods
    free_after_obs = free_before_obs - obs_required

    if free_after_obs >= 0:
        decision = "PASS"
        if free_after_obs <= 2:
            decision = "PASS_LOW_MARGIN"
        if recommended is None and decision == "PASS":
            recommended = candidate_nodes
    else:
        decision = "FAIL"

    print(f"{candidate_nodes},{total_capacity},{existing_after_scale},{free_before_obs},{obs_required},{free_after_obs},{decision}")

# Se nenhum PASS com margem aparecer, pega o primeiro PASS_LOW_MARGIN como mínimo técnico.
if recommended is None:
    for candidate_nodes in range(max(3, node_count), 7):
        total_capacity = candidate_nodes * per_node_pod_capacity
        existing_after_scale = existing_non_daemonset_pods + existing_daemonsets_per_node * candidate_nodes
        free_before_obs = total_capacity - existing_after_scale
        obs_required = (observability_daemonsets_per_node * candidate_nodes) + observability_singleton_pods + buffer_pods
        free_after_obs = free_before_obs - obs_required
        if free_after_obs >= 0:
            recommended = candidate_nodes
            break

print()
if recommended:
    print(f"RECOMMENDED_NODE_DESIRED_SIZE={recommended}")
    print(f"RECOMMENDED_NODE_MIN_SIZE=2")
    print(f"RECOMMENDED_NODE_MAX_SIZE={recommended}")
    print("RECOMMENDED_INSTANCE_TYPE=t3.small")
    print("RECOMMENDATION_REASON=Menor alteração possível: manter instance type atual e ampliar quantidade de nodes via IaC.")
else:
    print("RECOMMENDED_NODE_DESIRED_SIZE=UNDEFINED")
    print("RECOMMENDATION_REASON=Nenhum cenário até 6 nodes passou; avaliar troca de instance type antes da instalação.")
PY

cat "$TMP/capacity-options.txt"

{
  echo
  echo "### Cálculo de opções de capacidade"
  echo
  echo '```text'
  cat "$TMP/capacity-options.txt"
  echo
  echo '```'
} >> "$EVID"

RECOMMENDED_NODE_DESIRED_SIZE="$(grep '^RECOMMENDED_NODE_DESIRED_SIZE=' "$TMP/capacity-options.txt" | tail -1 | cut -d= -f2 || true)"
RECOMMENDED_NODE_MIN_SIZE="$(grep '^RECOMMENDED_NODE_MIN_SIZE=' "$TMP/capacity-options.txt" | tail -1 | cut -d= -f2 || true)"
RECOMMENDED_NODE_MAX_SIZE="$(grep '^RECOMMENDED_NODE_MAX_SIZE=' "$TMP/capacity-options.txt" | tail -1 | cut -d= -f2 || true)"
RECOMMENDED_INSTANCE_TYPE="$(grep '^RECOMMENDED_INSTANCE_TYPE=' "$TMP/capacity-options.txt" | tail -1 | cut -d= -f2 || true)"

if [ -z "$RECOMMENDED_NODE_DESIRED_SIZE" ] || [ "$RECOMMENDED_NODE_DESIRED_SIZE" = "UNDEFINED" ]; then
  echo "ERRO: não foi possível definir recomendação segura de quantidade de nodes."
  exit 30
fi

section "6. Decisão técnica"

cat > "$ADR" <<EOF
# ADR-003 - Correção de Capacidade para Observabilidade da Fase 4

## Status

Proposta aprovada para próximo bloco de alteração IaC, ainda sem apply nesta etapa.

## Contexto

O BLOCO 24 confirmou que o cluster atual não possui folga de pods para instalar a stack de observabilidade da Fase 4.

Estado observado:

- 2 nodes \`t3.small\`;
- 22 pods usados de 22 possíveis;
- 0 pods livres;
- necessidade estimada mínima: 14 pods livres para stack base e margem operacional.

A Fase 4 exige Prometheus, Grafana, Loki, OpenTelemetry Collector, APM, alertas, incidentes, ChatOps e self-healing operando na prática. Portanto, instalar a stack sem corrigir capacidade seria inseguro.

## Opções consideradas

### Opção A - Apenas subir para 3 nodes t3.small

Menor alteração possível, porém insuficiente conforme cálculo do BLOCO 25.

### Opção B - Subir para 4 nodes t3.small

Mantém o instance type atual e amplia a quantidade de nodes via IaC. É a menor alteração com capacidade calculada como viável no planejamento.

### Opção C - Trocar instance type

Pode resolver memória e pods com menos nodes, porém envolve maior impacto operacional no node group e maior risco no AWS Academy.

## Decisão

A decisão proposta é iniciar pela Opção B:

- manter \`t3.small\`;
- ajustar node group via Terraform para:
  - \`node_min_size = 2\`;
  - \`node_desired_size = $RECOMMENDED_NODE_DESIRED_SIZE\`;
  - \`node_max_size = $RECOMMENDED_NODE_MAX_SIZE\`.

## Consequências

- O próximo bloco deve alterar somente o código Terraform/IaC.
- Depois disso deve ser executado \`terraform plan\`.
- O \`terraform apply\` deve ocorrer em bloco separado, somente após revisão do plano.
- Após o apply, deve ser executado novo capacity gate.
- Só depois disso será permitido instalar a stack de observabilidade.

## Segurança

- Nenhuma credencial será versionada.
- Nenhum \`tfstate\`, \`terraform.tfvars\` real ou \`*.auto.tfvars\` será versionado.
- A execução seguirá AWS Academy com LabRole.
EOF

cat >> "$EVID" <<EOF

## Decisão técnica

A decisão proposta para o próximo bloco é alterar a capacidade do node group via IaC, sem trocar o tipo de instância inicialmente.

Valores recomendados:

- \`node_min_size = $RECOMMENDED_NODE_MIN_SIZE\`
- \`node_desired_size = $RECOMMENDED_NODE_DESIRED_SIZE\`
- \`node_max_size = $RECOMMENDED_NODE_MAX_SIZE\`
- \`node_instance_types = ["$RECOMMENDED_INSTANCE_TYPE"]\`

ADR gerada:

- \`$ADR\`

EOF

echo
echo "RECOMMENDED_NODE_MIN_SIZE=$RECOMMENDED_NODE_MIN_SIZE"
echo "RECOMMENDED_NODE_DESIRED_SIZE=$RECOMMENDED_NODE_DESIRED_SIZE"
echo "RECOMMENDED_NODE_MAX_SIZE=$RECOMMENDED_NODE_MAX_SIZE"
echo "RECOMMENDED_INSTANCE_TYPE=$RECOMMENDED_INSTANCE_TYPE"

section "7. Resultado"

cat >> "$EVID" <<EOF

## Resultado

BLOCO 25 concluído com sucesso.

Próximo bloco recomendado:

1. alterar Terraform para refletir a decisão;
2. rodar \`terraform fmt\` e \`terraform validate\`;
3. gerar \`terraform plan\`;
4. revisar o plano antes de qualquer apply.

EOF

echo
echo "============================================================"
echo "BLOCO 25 FINALIZADO"
echo "Plano de correção de capacidade gerado."
echo "Evidência: $EVID"
echo "ADR: $ADR"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
