#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco24-capacity-gate-observability.md"
LOG="$PHASE/docs/evidencias/fase4-bloco24-capacity-gate-observability.log"
TMP="$PHASE/tmp/bloco24"

APP_NS="togglemaster"
ARGO_NS="argocd"
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

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 24 - Gate de Capacidade para Observabilidade

Data: $(date)

## Objetivo

Avaliar se o cluster EKS atual comporta a stack de observabilidade da Fase 4 antes de instalar qualquer componente.

Este bloco é read-only e não altera infraestrutura.

EOM

echo "============================================================"
echo "FASE 4 - BLOCO 24 - GATE DE CAPACIDADE"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado Git"

record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -8

allowed_bloco24_status_filter() {
  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability\.md$|^\?\? fase4/scripts/24_capacity_gate_observability\.sh$|^\?\? fase4/scripts/$' || true
}

UNEXPECTED_STATUS="$(git status --short | allowed_bloco24_status_filter)"
if [ -n "$UNEXPECTED_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do BLOCO 24:"
  echo "$UNEXPECTED_STATUS"
  echo "- ERRO: Git tem alterações inesperadas no início do BLOCO 24." >> "$EVID"
  exit 10
fi

echo "OK: Git limpo, exceto artefatos esperados do próprio BLOCO 24."
echo "- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 24." >> "$EVID"

section "2. Estado atual do cluster"

export AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION"

record_cmd "AWS identity" aws sts get-caller-identity --output table
record_cmd "Contexto kubectl" kubectl config current-context
record_cmd "Nodes" kubectl get nodes -o wide
record_cmd "Namespaces" kubectl get ns
record_cmd "ArgoCD application" kubectl get application togglemaster-dev -n "$ARGO_NS" -o wide
record_cmd "Pods por namespace" kubectl get pods -A -o wide
record_cmd "Deployments togglemaster" kubectl get deployments -n "$APP_NS" -o wide
record_cmd "Services togglemaster" kubectl get svc -n "$APP_NS" -o wide

ARGO_STATUS="$(kubectl get application togglemaster-dev -n "$ARGO_NS" -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
PODS_NOT_READY="$(kubectl get pods -n "$APP_NS" --no-headers | awk '
{
  split($2, ready, "/");
  if (ready[1] != ready[2] || $3 != "Running") {
    print $0;
  }
}' || true)"

echo "ARGO_STATUS=$ARGO_STATUS"
echo "PODS_NOT_READY=${PODS_NOT_READY:-Nenhum}"

{
  echo
  echo "### Resultado Kubernetes/GitOps"
  echo
  echo "- ArgoCD: \`$ARGO_STATUS\`"
  if [ -n "$PODS_NOT_READY" ]; then
    echo "- Pods não prontos encontrados no namespace \`$APP_NS\`."
  else
    echo "- Pods não prontos no namespace \`$APP_NS\`: nenhum."
  fi
} >> "$EVID"

if [ "$ARGO_STATUS" != "Synced/Healthy" ]; then
  echo "ERRO: ArgoCD não está Synced/Healthy."
  exit 20
fi

if [ -n "$PODS_NOT_READY" ]; then
  echo "ERRO: existem pods não prontos no namespace $APP_NS."
  echo "$PODS_NOT_READY"
  exit 21
fi

section "3. Capacidade e consumo de pods"

kubectl get nodes -o json > "$TMP/nodes.json"
kubectl get pods -A -o json > "$TMP/pods.json"

python3 - <<'PY' | tee "$TMP/pod-capacity-report.txt"
import json
from pathlib import Path
from collections import defaultdict

nodes = json.loads(Path("fase4/tmp/bloco24/nodes.json").read_text())
pods = json.loads(Path("fase4/tmp/bloco24/pods.json").read_text())

node_capacity = {}
node_allocatable_cpu = {}
node_allocatable_mem = {}

for n in nodes.get("items", []):
    name = n["metadata"]["name"]
    alloc = n.get("status", {}).get("allocatable", {})
    node_capacity[name] = int(alloc.get("pods", "0"))
    node_allocatable_cpu[name] = alloc.get("cpu", "unknown")
    node_allocatable_mem[name] = alloc.get("memory", "unknown")

pods_by_node = defaultdict(list)
pods_by_ns = defaultdict(int)
unscheduled = []

for p in pods.get("items", []):
    ns = p["metadata"].get("namespace", "unknown")
    name = p["metadata"].get("name", "unknown")
    node = p.get("spec", {}).get("nodeName")
    phase = p.get("status", {}).get("phase", "unknown")
    pods_by_ns[ns] += 1

    if node:
        pods_by_node[node].append((ns, name, phase))
    else:
        unscheduled.append((ns, name, phase))

print("Resumo por node:")
total_capacity = 0
total_used = 0
total_remaining = 0

for node, capacity in sorted(node_capacity.items()):
    used = len(pods_by_node.get(node, []))
    remaining = capacity - used
    total_capacity += capacity
    total_used += used
    total_remaining += remaining

    print(f"- {node}")
    print(f"  allocatable.cpu={node_allocatable_cpu.get(node)}")
    print(f"  allocatable.memory={node_allocatable_mem.get(node)}")
    print(f"  pod.capacity={capacity}")
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

if unscheduled:
    print()
    print("Pods sem node:")
    for ns, name, phase in unscheduled:
        print(f"- {ns}/{name} phase={phase}")

# Estimativa conservadora para stack base:
# kube-prometheus-stack: operator, prometheus, alertmanager, grafana,
# kube-state-metrics, node-exporter daemonset por node.
# Loki: 1 pod.
# Promtail ou agente de logs: daemonset por node.
# OTel Collector: 1 pod inicial.
node_count = len(node_capacity)

estimated_daemonset_pods = node_count * 2  # node-exporter + promtail/agent
estimated_singleton_pods = 6              # operator, prometheus, alertmanager, grafana, kube-state, loki/otel extra
estimated_otel_pods = 1
estimated_total = estimated_daemonset_pods + estimated_singleton_pods + estimated_otel_pods

# Margem mínima para rollouts, coredns, reschedules e incidentes simulados.
required_buffer = 3
required_total_free = estimated_total + required_buffer

print()
print("Estimativa conservadora para observabilidade base:")
print(f"- ESTIMATED_DAEMONSET_PODS={estimated_daemonset_pods}")
print(f"- ESTIMATED_SINGLETON_PODS={estimated_singleton_pods}")
print(f"- ESTIMATED_OTEL_PODS={estimated_otel_pods}")
print(f"- ESTIMATED_OBSERVABILITY_PODS={estimated_total}")
print(f"- REQUIRED_BUFFER_PODS={required_buffer}")
print(f"- REQUIRED_TOTAL_FREE_PODS={required_total_free}")

if total_remaining >= required_total_free:
    print("CAPACITY_GATE=PASS")
    print("DECISION=Cluster aparenta ter folga de pods para iniciar stack base enxuta.")
else:
    print("CAPACITY_GATE=FAIL")
    print("DECISION=Cluster não tem folga suficiente de pods para instalar stack completa com segurança.")
PY

cat "$TMP/pod-capacity-report.txt"

{
  echo
  echo "### Relatório de capacidade de pods"
  echo
  echo '```text'
  cat "$TMP/pod-capacity-report.txt"
  echo
  echo '```'
} >> "$EVID"

CAPACITY_GATE="$(grep '^CAPACITY_GATE=' "$TMP/pod-capacity-report.txt" | tail -1 | cut -d= -f2 || true)"
TOTAL_REMAINING="$(grep '^TOTAL_PODS_REMAINING=' "$TMP/pod-capacity-report.txt" | tail -1 | cut -d= -f2 || true)"
REQUIRED_FREE="$(grep 'REQUIRED_TOTAL_FREE_PODS=' "$TMP/pod-capacity-report.txt" | tail -1 | sed 's/.*REQUIRED_TOTAL_FREE_PODS=//' || true)"

section "4. Requests e limits atuais"

record_cmd "Top nodes se metrics-server existir" bash -lc "kubectl top nodes 2>/dev/null || true"
record_cmd "Top pods se metrics-server existir" bash -lc "kubectl top pods -A 2>/dev/null || true"

record_cmd "Requests/limits dos pods por namespace" bash -lc "kubectl describe nodes | sed -n '/Allocated resources:/,/Events:/p' | head -220"

section "5. Node group e Terraform"

record_cmd "EKS nodegroups" aws eks list-nodegroups --cluster-name togglemaster-dev-eks --region "$AWS_REGION" --output table

set +e
NODEGROUPS="$(aws eks list-nodegroups --cluster-name togglemaster-dev-eks --region "$AWS_REGION" --query 'nodegroups[]' --output text 2>/dev/null || true)"
set -e

if [ -n "$NODEGROUPS" ]; then
  for ng in $NODEGROUPS; do
    record_cmd "Describe nodegroup $ng" aws eks describe-nodegroup \
      --cluster-name togglemaster-dev-eks \
      --nodegroup-name "$ng" \
      --region "$AWS_REGION" \
      --query 'nodegroup.{nodegroupName:nodegroupName,status:status,instanceTypes:instanceTypes,scalingConfig:scalingConfig,capacityType:capacityType}' \
      --output table
  done
else
  echo "AVISO: nenhum nodegroup retornado pela AWS CLI."
fi

record_cmd "Terraform EKS module" bash -lc "grep -RInE --exclude='*.tfstate' --exclude='*.tfstate.backup' --exclude='*.tfvars' --exclude='*.auto.tfvars' 'desired_size|min_size|max_size|instance_types|t3|node_group|node_group_desired' fase3/terraform/modules/eks fase3/terraform/environments/dev || true"

record_cmd "Terraform state/tfvars tracking check" bash -lc "git ls-files | grep -E '(^|/).*\\.tfstate(\\.backup)?$|(^|/)terraform\\.tfvars$|\\.auto\\.tfvars$' || true"

TRACKED_STATE_FILES="$(git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true)"
if [ -n "$TRACKED_STATE_FILES" ]; then
  echo "ERRO: arquivos de state/tfvars estão versionados, o que viola a regra de segurança:"
  echo "$TRACKED_STATE_FILES"
  echo "- ERRO: arquivos de state/tfvars versionados encontrados." >> "$EVID"
  exit 30
fi

echo "OK: nenhum tfstate/tfvars real está versionado."
echo "- OK: nenhum tfstate/tfvars real está versionado." >> "$EVID"

section "6. Decisão do gate"

cat >> "$EVID" <<EOF

## Decisão do gate

- CAPACITY_GATE: \`$CAPACITY_GATE\`
- Pods livres atuais: \`$TOTAL_REMAINING\`
- Pods livres recomendados para instalação segura: \`$REQUIRED_FREE\`

EOF

echo
echo "CAPACITY_GATE=$CAPACITY_GATE"
echo "TOTAL_PODS_REMAINING=$TOTAL_REMAINING"
echo "REQUIRED_TOTAL_FREE_PODS=$REQUIRED_FREE"

if [ "$CAPACITY_GATE" = "PASS" ]; then
  cat >> "$EVID" <<'EOF'

### Decisão

O cluster aparenta ter folga suficiente para iniciar a instalação de uma stack base enxuta de observabilidade.

Mesmo assim, a instalação deve ser feita em blocos pequenos, com validação após cada componente.

EOF

  echo "DECISÃO: pode iniciar stack base enxuta em blocos."
  RESULT_RC=0
else
  cat >> "$EVID" <<'EOF'

### Decisão

O cluster **não** aparenta ter folga suficiente para instalar a stack completa de observabilidade com segurança.

Antes de instalar Prometheus/Grafana/Loki/OTel, deve ser feita uma correção definitiva de capacidade, preferencialmente uma das opções:

1. aumentar o node group para 3 nodes, se o AWS Academy permitir;
2. ajustar instance type para uma opção com mais memória/pods, se permitido;
3. reduzir agressivamente a stack, instalando componentes mínimos em sequência, somente se a ampliação não for possível.

A recomendação técnica é não instalar observabilidade completa enquanto este gate estiver em FAIL.

EOF

  echo "DECISÃO: não instalar stack completa ainda; corrigir capacidade primeiro."
  RESULT_RC=24
fi

section "7. Resultado"

cat >> "$EVID" <<EOF

## Resultado

- Gate de capacidade executado.
- Resultado: \`$CAPACITY_GATE\`
- Log: \`$LOG\`

EOF

echo
echo "============================================================"
echo "BLOCO 24 FINALIZADO"
echo "CAPACITY_GATE=$CAPACITY_GATE"
echo "RESULT_RC=$RESULT_RC"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "Terminal continua vivo."
echo "============================================================"

exit "$RESULT_RC"
