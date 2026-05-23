#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md"
LOG="$PHASE/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.log"
TMP="$PHASE/tmp/bloco30"

ARGO_NS="argocd"
OBS_NS="observability"

APP_NS_FILE="fase4/gitops/apps/observability/namespace-application.yaml"
APP_KPS_FILE="fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml"

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

retry_cmd() {
  local attempts="$1"
  local sleep_seconds="$2"
  shift 2

  local rc=0

  for attempt in $(seq 1 "$attempts"); do
    echo "Tentativa $attempt/$attempts: $*"
    set +e
    "$@"
    rc=$?
    set -e

    if [ "$rc" -eq 0 ]; then
      return 0
    fi

    echo "Comando falhou com rc=$rc. Aguardando ${sleep_seconds}s antes de tentar novamente..."
    sleep "$sleep_seconds"
  done

  return "$rc"
}

retry_bash() {
  local attempts="$1"
  local sleep_seconds="$2"
  local command="$3"

  local rc=0

  for attempt in $(seq 1 "$attempts"); do
    echo "Tentativa $attempt/$attempts: $command"
    set +e
    bash -lc "$command"
    rc=$?
    set -e

    if [ "$rc" -eq 0 ]; then
      return 0
    fi

    echo "Comando falhou com rc=$rc. Aguardando ${sleep_seconds}s antes de tentar novamente..."
    sleep "$sleep_seconds"
  done

  return "$rc"
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
  "$@" > "$TMP/last.out" 2>&1
  local rc=$?
  set -e

  cat "$TMP/last.out"

  {
    cat "$TMP/last.out"
    echo
    echo '```'
    echo
    echo "RC: \`$rc\`"
  } >> "$EVID"

  echo
  echo "RC=$rc"
  return "$rc"
}

wait_argocd_app() {
  local app="$1"
  local max_attempts="${2:-60}"
  local sleep_seconds="${3:-10}"

  echo
  echo "Aguardando ArgoCD Application: $app"

  for attempt in $(seq 1 "$max_attempts"); do
    local sync health
    sync="$(kubectl get application "$app" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
    health="$(kubectl get application "$app" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"

    echo "Tentativa $attempt/$max_attempts - $app sync=${sync:-N/A} health=${health:-N/A}"

    if [ "$sync" = "Synced" ] && [ "$health" = "Healthy" ]; then
      echo "$app Synced/Healthy"
      return 0
    fi

    sleep "$sleep_seconds"
  done

  echo "ERRO: $app não ficou Synced/Healthy dentro do tempo esperado."
  kubectl describe application "$app" -n "$ARGO_NS" || true
  return 1
}

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 30 - Aplicação Prometheus/Grafana via ArgoCD

Data: $(date)

## Objetivo

Aplicar a primeira parte da stack de observabilidade da Fase 4:

- namespace \`observability\`;
- \`kube-prometheus-stack\`, incluindo Prometheus, Grafana, Alertmanager, kube-state-metrics e node-exporter.

Este bloco não instala Loki, Promtail, OpenTelemetry Collector, APM externo, incident management, ChatOps ou self-healing.

EOM

echo "============================================================"
echo "FASE 4 - BLOCO 30 - PROMETHEUS/GRAFANA VIA ARGOCD"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado inicial"

record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -8
record_cmd "Cluster nodes" retry_cmd 6 10 kubectl get nodes -o wide
record_cmd "ArgoCD ToggleMaster" retry_cmd 6 10 kubectl get application togglemaster-dev -n "$ARGO_NS" -o wide
record_cmd "Pods antes da observabilidade" retry_cmd 8 10 kubectl get pods -A -o wide

allowed_bloco30_status_filter() {
  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd\.md$|^\?\? fase4/scripts/30_apply_prometheus_grafana_argocd\.sh$|^\?\? fase4/scripts/$' || true
}

UNEXPECTED_STATUS="$(git status --short | allowed_bloco30_status_filter)"
if [ -n "$UNEXPECTED_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do BLOCO 30:"
  echo "$UNEXPECTED_STATUS"
  exit 10
fi

section "2. Validar manifests antes do apply"

test -f "$APP_NS_FILE"
test -f "$APP_KPS_FILE"

record_cmd "Kustomize apps observability" kubectl kustomize fase4/gitops/apps/observability
record_cmd "Manifest namespace application" cat "$APP_NS_FILE"
record_cmd "Manifest kube-prometheus-stack application" cat "$APP_KPS_FILE"

section "3. Aplicar namespace Application"

record_cmd "kubectl apply namespace application" retry_cmd 4 10 kubectl apply -f "$APP_NS_FILE"

wait_argocd_app "observability-namespace" 30 10

record_cmd "Namespace observability" retry_cmd 6 10 kubectl get ns "$OBS_NS" -o wide

section "4. Aplicar kube-prometheus-stack Application"

record_cmd "kubectl apply kube-prometheus-stack application" retry_cmd 4 10 kubectl apply -f "$APP_KPS_FILE"

wait_argocd_app "observability-kube-prometheus-stack" 90 15

section "5. Validar recursos instalados"

record_cmd "ArgoCD observability apps" retry_bash 6 10 "kubectl get applications -n \"$ARGO_NS\" | grep -E 'observability|NAME'"
record_cmd "Pods observability" retry_cmd 8 10 kubectl get pods -n "$OBS_NS" -o wide
record_cmd "Services observability" retry_cmd 6 10 kubectl get svc -n "$OBS_NS" -o wide
record_cmd "Deployments observability" retry_cmd 6 10 kubectl get deployments -n "$OBS_NS" -o wide
record_cmd "StatefulSets observability" retry_cmd 6 10 kubectl get statefulsets -n "$OBS_NS" -o wide
record_cmd "DaemonSets observability" retry_cmd 6 10 kubectl get daemonsets -n "$OBS_NS" -o wide

section "6. Checagem de readiness"

NOT_READY="$(kubectl get pods -n "$OBS_NS" --no-headers 2>/dev/null | awk '
{
  split($2, ready, "/");
  if (ready[1] != ready[2] || $3 != "Running") {
    print $0;
  }
}' || true)"

{
  echo
  echo "### Pods não prontos"
  echo
  echo '```text'
  if [ -n "$NOT_READY" ]; then
    echo "$NOT_READY"
  else
    echo "Nenhum pod não pronto no namespace observability."
  fi
  echo '```'
} >> "$EVID"

if [ -n "$NOT_READY" ]; then
  echo "ERRO: existem pods não prontos no namespace observability."
  echo "$NOT_READY"
  exit 20
fi

section "7. Capacity check pós-instalação Prometheus/Grafana"

kubectl get nodes -o json > "$TMP/nodes.json"
kubectl get pods -A -o json > "$TMP/pods.json"

python3 - <<'PY' > "$TMP/capacity.txt"
import json
from pathlib import Path
from collections import defaultdict

nodes = json.loads(Path("fase4/tmp/bloco30/nodes.json").read_text())
pods = json.loads(Path("fase4/tmp/bloco30/pods.json").read_text())

node_capacity = {}
pods_by_node = defaultdict(list)
pods_by_ns = defaultdict(int)

for n in nodes.get("items", []):
    name = n["metadata"]["name"]
    alloc = n.get("status", {}).get("allocatable", {})
    node_capacity[name] = int(alloc.get("pods", "0"))

for p in pods.get("items", []):
    ns = p["metadata"].get("namespace", "unknown")
    node = p.get("spec", {}).get("nodeName")
    pods_by_ns[ns] += 1
    if node:
        pods_by_node[node].append(p)

total_capacity = sum(node_capacity.values())
total_used = sum(len(pods_by_node[n]) for n in node_capacity)
total_remaining = total_capacity - total_used

print(f"TOTAL_POD_CAPACITY={total_capacity}")
print(f"TOTAL_PODS_USED={total_used}")
print(f"TOTAL_PODS_REMAINING={total_remaining}")
print("Pods por namespace:")
for ns, count in sorted(pods_by_ns.items()):
    print(f"- {ns}: {count}")
print("Pods por node:")
for node in sorted(node_capacity):
    used = len(pods_by_node[node])
    print(f"- {node}: used={used} remaining={node_capacity[node]-used}")
PY

cat "$TMP/capacity.txt"

{
  echo
  echo "### Capacity check pós-instalação"
  echo
  echo '```text'
  cat "$TMP/capacity.txt"
  echo '```'
} >> "$EVID"

section "8. Resultado"

cat >> "$EVID" <<'EOF'

## Resultado

BLOCO 30 concluído com sucesso.

Componentes aplicados:

- `observability-namespace`
- `observability-kube-prometheus-stack`

Validações realizadas:

- ArgoCD Applications Synced/Healthy;
- pods do namespace `observability` Running/Ready;
- services, deployments, statefulsets e daemonsets listados;
- capacity check pós-instalação registrado.

Ainda não foram instalados:

- Loki;
- Promtail;
- OpenTelemetry Collector;
- APM externo;
- Incident Management;
- ChatOps;
- Self-healing.

EOF

echo
echo "============================================================"
echo "BLOCO 30 FINALIZADO"
echo "Prometheus/Grafana aplicados via ArgoCD."
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
