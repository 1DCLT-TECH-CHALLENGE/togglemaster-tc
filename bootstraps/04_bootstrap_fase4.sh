#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
cd "$ROOT"

section "ToggleMaster TC - Bootstrap Fase 4"
echo "Escopo:"
echo "- Observabilidade, métricas, logs, APM, alertas, incidentes, ChatOps e self-healing."
echo "- Requer Fase 3 cloud ativa."
echo
echo "Secrets opcionais por variável de ambiente:"
echo "- NEW_RELIC_LICENSE_KEY"
echo "- PAGERDUTY_ROUTING_KEY"
echo "- DISCORD_WEBHOOK_URL"

if [ "${BOOTSTRAP_SKIP_PREPARE_VM:-false}" != "true" ]; then
  run_script "$ROOT/bootstraps/00_prepare_vm.sh"
fi

require_cmd kubectl
require_cmd helm

section "Validando cluster Kubernetes"
kubectl config current-context
kubectl get nodes

section "Namespace observability"
kubectl create namespace observability --dry-run=client -o yaml | kubectl apply -f -

section "Secrets externos, se fornecidos"
if [ -n "${NEW_RELIC_LICENSE_KEY:-}" ]; then
  kubectl -n observability create secret generic newrelic-otel-secret \
    --from-literal=NEW_RELIC_LICENSE_KEY="$NEW_RELIC_LICENSE_KEY" \
    --dry-run=client -o yaml | kubectl apply -f -
else
  warn "NEW_RELIC_LICENSE_KEY não definido. New Relic pode exigir configuração posterior."
fi

if [ -n "${PAGERDUTY_ROUTING_KEY:-}" ] || [ -n "${DISCORD_WEBHOOK_URL:-}" ]; then
  kubectl -n observability create secret generic incident-bridge-secret \
    --from-literal=PAGERDUTY_ROUTING_KEY="${PAGERDUTY_ROUTING_KEY:-}" \
    --from-literal=DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-}" \
    --dry-run=client -o yaml | kubectl apply -f -
else
  warn "PagerDuty/Discord não definidos. Incident Bridge/ChatOps podem exigir configuração posterior."
fi

section "Executando scripts principais da Fase 4"
scripts=(
  "fase4/scripts/23_inventory_phase4_stack.sh"
  "fase4/scripts/24_capacity_gate_observability.sh"
  "fase4/scripts/29_prepare_observability_gitops.sh"
  "fase4/scripts/30_apply_prometheus_grafana_argocd.sh"
  "fase4/scripts/31_validate_grafana_access.sh"
  "fase4/scripts/32_apply_grafana_dashboard.sh"
  "fase4/scripts/33_12_finalize_promtail_loki.sh"
  "fase4/scripts/34_apply_otel_collector_gitops.sh"
)

for s in "${scripts[@]}"; do
  if [ -f "$ROOT/$s" ]; then
    run_script "$ROOT/$s"
  else
    warn "Script não encontrado, seguindo: $s"
  fi
done

section "Aplicando Applications GitOps da observabilidade"
kubectl apply -k fase4/gitops/apps/observability

section "Validando ArgoCD Applications"
kubectl get applications -n argocd || true

section "Self-healing"
if [ "${BOOTSTRAP_RUN_SELF_HEALING:-false}" = "true" ]; then
  run_script "$ROOT/fase4/self-healing/scripts/01_self_healing_rollout_restart.sh"
else
  echo "Self-healing não executado automaticamente."
  echo "Para executar:"
  echo "BOOTSTRAP_RUN_SELF_HEALING=true $ROOT/bootstraps/04_bootstrap_fase4.sh"
fi

section "Fase 4 concluída"
echo "Stack de observabilidade/APM/incidentes/ChatOps/self-healing aplicada conforme secrets disponíveis."
