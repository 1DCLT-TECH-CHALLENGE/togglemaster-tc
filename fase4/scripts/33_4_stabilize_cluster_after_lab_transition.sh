#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco33-4-cluster-stabilization-after-lab.md"
LOG="$PHASE/docs/evidencias/fase4-bloco33-4-cluster-stabilization-after-lab.log"
TMP="$PHASE/tmp/bloco33-4"

REGION="us-east-1"
CLUSTER_NAME="togglemaster-dev-eks"
ARGO_NS="argocd"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 33.4 - Estabilização do cluster após transição do AWS Academy Lab

Data: $(date)

## Objetivo

Estabilizar o cluster EKS antes de retomar Loki/Promtail.

O checkpoint anterior mostrou nodes antigos em \`NotReady,SchedulingDisabled\`, taints de \`shutdown/unreachable\` e muitos pods em \`Terminating\`. Este bloco faz inventário seguro e remove apenas objetos Node órfãos quando houver confirmação de que o node não deve mais participar do cluster.

EOM

record_section() {
  local title="$1"
  shift

  echo
  echo "============================================================"
  echo "$title"
  echo "============================================================"
  echo

  {
    echo
    echo "## $title"
    echo
    echo '```text'
  } >> "$EVID"

  set +e
  "$@" > "$TMP/last.out" 2>&1
  local rc=$?
  set -e

  cat "$TMP/last.out"

  {
    cat "$TMP/last.out"
    echo '```'
    echo
    echo "RC: \`$rc\`"
  } >> "$EVID"

  return "$rc"
}

echo "[1/11] Validando credenciais AWS"
record_section "AWS identity" aws sts get-caller-identity --output table

echo
echo "[2/11] Atualizando kubeconfig"
record_section "Update kubeconfig" aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo
echo "[3/11] Estado inicial do cluster"
record_section "Nodes iniciais" kubectl get nodes -o wide
record_section "Applications ArgoCD iniciais" kubectl get application -n "$ARGO_NS"
record_section "Pods problemáticos iniciais" bash -lc "kubectl get pods -A -o wide | grep -E 'Terminating|Pending|CrashLoopBackOff|Error' || true"

echo
echo "[4/11] Coletando JSON de nodes"
kubectl get nodes -o json > "$TMP/nodes.json"

echo
echo "[5/11] Mapeando nodes para instâncias EC2"
python3 - <<'PY' > "fase4/tmp/bloco33-4/node-inventory.tsv"
import json
import re
from pathlib import Path

nodes = json.loads(Path("fase4/tmp/bloco33-4/nodes.json").read_text())

print("node\tready\tunschedulable\tshutdown_taint\tunreachable_taint\tinstance_id\tprovider_id")

for n in nodes.get("items", []):
    name = n["metadata"]["name"]
    spec = n.get("spec", {})
    status = n.get("status", {})
    provider_id = spec.get("providerID", "")
    instance_id = ""
    m = re.search(r"/(i-[a-zA-Z0-9]+)$", provider_id)
    if m:
        instance_id = m.group(1)

    unsched = str(spec.get("unschedulable", False)).lower()
    taints = spec.get("taints", []) or []
    shutdown_taint = any(t.get("key") == "node.cloudprovider.kubernetes.io/shutdown" for t in taints)
    unreachable_taint = any(t.get("key") == "node.kubernetes.io/unreachable" for t in taints)

    ready = "Unknown"
    for c in status.get("conditions", []):
        if c.get("type") == "Ready":
            ready = c.get("status")
            break

    print(f"{name}\t{ready}\t{unsched}\t{str(shutdown_taint).lower()}\t{str(unreachable_taint).lower()}\t{instance_id}\t{provider_id}")
PY

cat "$TMP/node-inventory.tsv"

{
  echo
  echo "## Inventário Kubernetes nodes"
  echo
  echo '```text'
  cat "$TMP/node-inventory.tsv"
  echo '```'
} >> "$EVID"

INSTANCE_IDS="$(awk 'NR>1 && $6 != "" {print $6}' "$TMP/node-inventory.tsv" | sort -u | tr '\n' ' ')"

if [ -n "$INSTANCE_IDS" ]; then
  aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids $INSTANCE_IDS \
    --query 'Reservations[].Instances[].{InstanceId:InstanceId,PrivateDnsName:PrivateDnsName,PrivateIpAddress:PrivateIpAddress,State:State.Name}' \
    --output json > "$TMP/ec2-instances.json" || true
else
  echo "[]" > "$TMP/ec2-instances.json"
fi

python3 - <<'PY' > "fase4/tmp/bloco33-4/ec2-inventory.tsv"
import json
from pathlib import Path

data = json.loads(Path("fase4/tmp/bloco33-4/ec2-instances.json").read_text() or "[]")
print("instance_id\tprivate_dns\tprivate_ip\tstate")
for item in data:
    print(f"{item.get('InstanceId','')}\t{item.get('PrivateDnsName','')}\t{item.get('PrivateIpAddress','')}\t{item.get('State','')}")
PY

cat "$TMP/ec2-inventory.tsv"

{
  echo
  echo "## Inventário EC2 das instâncias associadas aos nodes"
  echo
  echo '```text'
  cat "$TMP/ec2-inventory.tsv"
  echo '```'
} >> "$EVID"

echo
echo "[6/11] Selecionando nodes órfãos para remoção segura"
python3 - <<'PY' > "fase4/tmp/bloco33-4/nodes-to-delete.txt"
from pathlib import Path

node_lines = Path("fase4/tmp/bloco33-4/node-inventory.tsv").read_text().splitlines()[1:]
ec2_lines = Path("fase4/tmp/bloco33-4/ec2-inventory.tsv").read_text().splitlines()[1:]

ec2_state = {}
for line in ec2_lines:
    parts = line.split("\t")
    if len(parts) >= 4:
        ec2_state[parts[0]] = parts[3]

for line in node_lines:
    node, ready, unsched, shutdown_taint, unreachable_taint, instance_id, provider_id = line.split("\t")

    state = ec2_state.get(instance_id, "not-found") if instance_id else "not-found"

    safe_to_delete = (
        ready != "True"
        and unsched == "true"
        and (
            shutdown_taint == "true"
            or state in {"terminated", "shutting-down", "stopped", "stopping", "not-found"}
        )
    )

    if safe_to_delete:
        print(node)
PY

if [ -s "$TMP/nodes-to-delete.txt" ]; then
  echo "Nodes selecionados para remoção segura:"
  cat "$TMP/nodes-to-delete.txt"
else
  echo "Nenhum node órfão selecionado para remoção."
fi

{
  echo
  echo "## Nodes selecionados para remoção segura"
  echo
  echo '```text'
  if [ -s "$TMP/nodes-to-delete.txt" ]; then
    cat "$TMP/nodes-to-delete.txt"
  else
    echo "Nenhum node órfão selecionado."
  fi
  echo '```'
} >> "$EVID"

echo
echo "[7/11] Removendo somente objetos Node órfãos confirmados"
if [ -s "$TMP/nodes-to-delete.txt" ]; then
  while read -r node; do
    [ -z "$node" ] && continue
    echo "Removendo objeto Node órfão: $node"
    kubectl delete node "$node" --ignore-not-found
  done < "$TMP/nodes-to-delete.txt"
else
  echo "Sem remoção de nodes."
fi

echo
echo "[8/11] Aguardando estabilização pós-limpeza"
sleep 20

record_section "Nodes após limpeza" kubectl get nodes -o wide
record_section "Pods problemáticos após limpeza" bash -lc "kubectl get pods -A -o wide | grep -E 'Terminating|Pending|CrashLoopBackOff|Error' || true"
record_section "Applications após limpeza" kubectl get application -n "$ARGO_NS"

echo
echo "[9/11] Validando mínimo operacional de nodes Ready"
READY_COUNT="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 == "Ready" {c++} END {print c+0}')"
TOTAL_COUNT="$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"

echo "READY_COUNT=$READY_COUNT"
echo "TOTAL_COUNT=$TOTAL_COUNT"

{
  echo
  echo "## Contagem final de nodes"
  echo
  echo '```text'
  echo "READY_COUNT=$READY_COUNT"
  echo "TOTAL_COUNT=$TOTAL_COUNT"
  echo '```'
} >> "$EVID"

if [ "$READY_COUNT" -lt 3 ]; then
  echo "ERRO: menos de 3 nodes Ready após estabilização. Não prosseguir com Loki."
  exit 20
fi

echo
echo "[10/11] Git e segurança"
if git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$|(^|/).*tfplan.*|(^|/).*\.bin$'; then
  echo "ERRO: state/tfvars/plan binário versionado detectado."
  exit 30
else
  echo "OK: nenhum state/tfvars/plan binário versionado."
fi

echo
echo "[11/11] Resultado"
{
  echo
  echo "## Resultado"
  echo
  echo "- Credenciais AWS/EKS validadas."
  echo "- Nodes inventariados e comparados com EC2."
  echo "- Objetos Node órfãos removidos apenas quando seguro."
  echo "- Cluster estabilizado para nova tentativa de diagnóstico Loki."
  echo "- Próximo passo: diagnosticar `observability-loki` e corrigir values/ArgoCD antes de aplicar Promtail."
} >> "$EVID"

echo
echo "============================================================"
echo "BLOCO 33.4 FINALIZADO"
echo "READY_COUNT=$READY_COUNT"
echo "TOTAL_COUNT=$TOTAL_COUNT"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
