#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco32-grafana-dashboard-customizado.md"
LOG="$PHASE/docs/evidencias/fase4-bloco32-grafana-dashboard-customizado.log"
TMP="$PHASE/tmp/bloco32"

ARGO_NS="argocd"
OBS_NS="observability"
APP="observability-dashboards"
APP_FILE="fase4/gitops/apps/observability/dashboards-application.yaml"
GRAFANA_SVC="kube-prometheus-stack-grafana"
LOCAL_PORT="13000"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cleanup() {
  if [ -n "${PF_PID:-}" ]; then
    echo
    echo "Cleanup: encerrando port-forward Grafana..."
    kill "$PF_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 32 - Dashboard Customizado do Grafana

Data: $(date)

## Objetivo

Aplicar e validar o dashboard customizado do ToggleMaster no Grafana, usando GitOps/ArgoCD.

Este bloco:

- aplica a ArgoCD Application \`observability-dashboards\`;
- valida o ConfigMap do dashboard;
- valida que o Grafana importou o dashboard;
- não expõe senha do Grafana na evidência.

EOM

echo "[1/9] Estado inicial"
git status --short
kubectl get application observability-kube-prometheus-stack -n "$ARGO_NS" -o wide
kubectl get pods -n "$OBS_NS" -o wide
kubectl get deployment kube-prometheus-stack-grafana -n "$OBS_NS" -o wide

echo
echo "[2/9] Validando manifesto do dashboard"
test -f "$APP_FILE"
test -f "fase4/gitops/observability/dashboards/togglemaster-grafana-dashboard.yaml"
test -f "fase4/dashboards/grafana/togglemaster-ecosystem-dashboard.json"

kubectl kustomize fase4/gitops/observability/dashboards > "$TMP/dashboard-render.yaml"
kubectl kustomize fase4/gitops/apps/observability > "$TMP/apps-render.yaml"

echo "OK: kustomize render dos dashboards e apps passou."

echo
echo "[3/9] Aplicando ArgoCD Application de dashboards"
kubectl apply -f "$APP_FILE"

echo
echo "[4/9] Aguardando observability-dashboards Synced/Healthy"
for attempt in $(seq 1 40); do
  sync="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  echo "Tentativa $attempt/40 - $APP sync=${sync:-N/A} health=${health:-N/A}"

  if [ "$sync" = "Synced" ] && [ "$health" = "Healthy" ]; then
    echo "$APP Synced/Healthy"
    break
  fi

  sleep 10
done

kubectl get application "$APP" -n "$ARGO_NS" -o wide
APP_SYNC="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
APP_HEALTH="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"

if [ "$APP_SYNC" != "Synced" ] || [ "$APP_HEALTH" != "Healthy" ]; then
  echo "ERRO: $APP não ficou Synced/Healthy."
  kubectl describe application "$APP" -n "$ARGO_NS" || true
  exit 20
fi

echo
echo "[5/9] Validando ConfigMap do dashboard"
kubectl get cm togglemaster-grafana-dashboard -n "$OBS_NS" -o wide
kubectl get cm togglemaster-grafana-dashboard -n "$OBS_NS" -o jsonpath='{.metadata.labels.grafana_dashboard}{"\n"}' > "$TMP/dashboard-label.txt"

if [ "$(cat "$TMP/dashboard-label.txt")" != "1" ]; then
  echo "ERRO: ConfigMap do dashboard não tem label grafana_dashboard=1."
  exit 30
fi

echo "OK: ConfigMap do dashboard com label grafana_dashboard=1."

echo
echo "[6/9] Aguardando sidecar do Grafana importar dashboard"
GRAFANA_USER="admin"
GRAFANA_PASS="$(kubectl get secret kube-prometheus-stack-grafana -n "$OBS_NS" -o jsonpath='{.data.admin-password}' | base64 -d)"

if [ -z "$GRAFANA_PASS" ]; then
  echo "ERRO: senha admin do Grafana não encontrada."
  exit 40
fi

pkill -f "kubectl.*port-forward.*${GRAFANA_SVC}.*${LOCAL_PORT}:80" >/dev/null 2>&1 || true
kubectl -n "$OBS_NS" port-forward "svc/$GRAFANA_SVC" "${LOCAL_PORT}:80" > "$TMP/grafana-port-forward.log" 2>&1 &
PF_PID=$!

sleep 5

if ! kill -0 "$PF_PID" >/dev/null 2>&1; then
  echo "ERRO: port-forward não ficou ativo."
  cat "$TMP/grafana-port-forward.log" || true
  exit 50
fi

CUSTOM_DASHBOARD_FOUND="false"

for attempt in $(seq 1 24); do
  echo "Tentativa $attempt/24 - buscando dashboard ToggleMaster na API do Grafana"

  curl -sS -u "${GRAFANA_USER}:${GRAFANA_PASS}" \
    "http://localhost:${LOCAL_PORT}/api/search?type=dash-db" \
    > "$TMP/grafana-dashboards.json"

  python3 - "$TMP/grafana-dashboards.json" > "$TMP/dashboard-check.txt" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())

for item in data:
    title = item.get("title") or ""
    uid = item.get("uid") or ""
    folder = item.get("folderTitle")
    if "ToggleMaster" in title:
        print(f"CUSTOM_DASHBOARD_FOUND=true")
        print(f"title={title}")
        print(f"uid={uid}")
        print(f"folder={folder}")
        raise SystemExit(0)

print("CUSTOM_DASHBOARD_FOUND=false")
PY

  cat "$TMP/dashboard-check.txt"

  CUSTOM_DASHBOARD_FOUND="$(grep 'CUSTOM_DASHBOARD_FOUND=' "$TMP/dashboard-check.txt" | tail -1 | cut -d= -f2 || true)"

  if [ "$CUSTOM_DASHBOARD_FOUND" = "true" ]; then
    break
  fi

  sleep 10
done

if [ "$CUSTOM_DASHBOARD_FOUND" != "true" ]; then
  echo "ERRO: dashboard ToggleMaster não apareceu no Grafana após aguardar."
  echo "Dashboards atuais:"
  python3 - "$TMP/grafana-dashboards.json" <<'PY'
import json
import sys
from pathlib import Path
data = json.loads(Path(sys.argv[1]).read_text())
for item in data[:50]:
    print(f"- title={item.get('title')} uid={item.get('uid')} folder={item.get('folderTitle')}")
PY
  exit 60
fi

echo
echo "[7/9] Validando saúde final do Grafana"
curl -sS -u "${GRAFANA_USER}:${GRAFANA_PASS}" "http://localhost:${LOCAL_PORT}/api/health" > "$TMP/grafana-health.json"
cat "$TMP/grafana-health.json"

echo
echo "[8/9] Registrando evidência sem senha"
{
  echo
  echo "## Resultado"
  echo
  echo "- Application ArgoCD: \`$APP\`"
  echo "- Application status: \`$APP_SYNC/$APP_HEALTH\`"
  echo "- ConfigMap: \`togglemaster-grafana-dashboard\`"
  echo "- Label do ConfigMap: \`grafana_dashboard=1\`"
  echo "- Dashboard ToggleMaster encontrado no Grafana: \`$CUSTOM_DASHBOARD_FOUND\`"
  echo
  echo "### Application"
  echo
  echo '```text'
  kubectl get application "$APP" -n "$ARGO_NS" -o wide
  echo '```'
  echo
  echo "### ConfigMap"
  echo
  echo '```text'
  kubectl get cm togglemaster-grafana-dashboard -n "$OBS_NS" -o wide
  echo '```'
  echo
  echo "### Dashboard encontrado"
  echo
  echo '```text'
  cat "$TMP/dashboard-check.txt"
  echo '```'
  echo
  echo "### Grafana health"
  echo
  echo '```json'
  cat "$TMP/grafana-health.json"
  echo
  echo '```'
} >> "$EVID"

echo
echo "[9/9] Resultado"
echo "CUSTOM_DASHBOARD_FOUND=$CUSTOM_DASHBOARD_FOUND"
echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"

echo
echo "============================================================"
echo "BLOCO 32 FINALIZADO"
echo "Dashboard customizado aplicado e validado."
echo "CUSTOM_DASHBOARD_FOUND=$CUSTOM_DASHBOARD_FOUND"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
