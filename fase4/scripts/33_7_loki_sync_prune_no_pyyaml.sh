#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco33-7-loki-sync-prune-no-pyyaml.md"
LOG="$PHASE/docs/evidencias/fase4-bloco33-7-loki-sync-prune-no-pyyaml.log"
TMP="$PHASE/tmp/bloco33-7"

APP="observability-loki"
ARGO_NS="argocd"
OBS_NS="observability"
VALUES="fase4/gitops/observability/values/loki-values.yaml"
APP_FILE="fase4/gitops/apps/observability/loki-application.yaml"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 33.7 - Sync/prune Loki sem PyYAML

Data: $(date)

## Objetivo

Executar sync/prune do Loki no ArgoCD sem depender do módulo Python \`yaml\`, confirmar se os caches antigos foram removidos e registrar logs objetivos do \`loki-0\`.

EOM

echo "[1/12] Estado inicial"
git status --short
git log --oneline --decorate -8
kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
kubectl get statefulsets -n "$OBS_NS" | grep -E 'NAME|loki' || true
kubectl get svc -n "$OBS_NS" | grep -E 'NAME|loki' || true

{
  echo
  echo "## Estado inicial"
  echo
  echo '```text'
  git log --oneline --decorate -8
  kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
  kubectl get statefulsets -n "$OBS_NS" | grep -E 'NAME|loki' || true
  kubectl get svc -n "$OBS_NS" | grep -E 'NAME|loki' || true
  echo '```'
} >> "$EVID"

echo
echo "[2/12] Inspecionando Application via JSON"
kubectl get application "$APP" -n "$ARGO_NS" -o json > "$TMP/app-before.json"

python3 - "$TMP/app-before.json" > "$TMP/app-summary.txt" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())
spec = data.get("spec", {})
status = data.get("status", {})

print("Application source/sources:")
if "source" in spec:
    print(json.dumps(spec["source"], indent=2, sort_keys=True))
if "sources" in spec:
    print(json.dumps(spec["sources"], indent=2, sort_keys=True))

print("Application syncPolicy:")
print(json.dumps(spec.get("syncPolicy", {}), indent=2, sort_keys=True))

print("Application status:")
print(json.dumps({
    "sync": status.get("sync", {}),
    "health": status.get("health", {}),
    "operationState": status.get("operationState", {}),
}, indent=2, sort_keys=True))
PY

cat "$TMP/app-summary.txt"

{
  echo
  echo "## Application ArgoCD"
  echo
  echo '```json'
  cat "$TMP/app-summary.txt"
  echo '```'
} >> "$EVID"

echo
echo "[3/12] Confirmando render local sem caches"
grep -nE 'chunksCache|resultsCache|enabled: false' "$VALUES" || true

LOKI_VERSION="$(python3 - <<'PY'
from pathlib import Path
import re
text = Path("fase4/gitops/apps/observability/loki-application.yaml").read_text()
m = re.search(r"targetRevision:\s*['\"]?([^'\"\s]+)", text)
if not m:
    raise SystemExit("targetRevision não encontrado")
print(m.group(1))
PY
)"

echo "LOKI_VERSION=$LOKI_VERSION"

helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1

helm template loki grafana/loki \
  --version "$LOKI_VERSION" \
  --namespace "$OBS_NS" \
  -f "$VALUES" > "$TMP/loki-render.yaml"

if grep -qE 'name: loki-(chunks-cache|results-cache)' "$TMP/loki-render.yaml"; then
  echo "ERRO: render local ainda contém caches."
  grep -nE 'name: loki-(chunks-cache|results-cache)' "$TMP/loki-render.yaml" || true
  exit 10
fi

echo "OK: render local não contém chunks-cache/results-cache."

echo
echo "[4/12] Recursos ArgoCD antes do sync/prune"
kubectl get application "$APP" -n "$ARGO_NS" \
  -o jsonpath='{range .status.resources[*]}{.kind}{"\t"}{.namespace}{"\t"}{.name}{"\t"}{.status}{"\t"}{.health.status}{"\n"}{end}' \
  | sort || true

{
  echo
  echo "## Recursos antes do sync/prune"
  echo
  echo '```text'
  kubectl get application "$APP" -n "$ARGO_NS" \
    -o jsonpath='{range .status.resources[*]}{.kind}{"\t"}{.namespace}{"\t"}{.name}{"\t"}{.status}{"\t"}{.health.status}{"\n"}{end}' \
    | sort || true
  echo '```'
} >> "$EVID"

echo
echo "[5/12] Refresh hard"
kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true
sleep 20

echo
echo "[6/12] Solicitar sync/prune via ArgoCD Application operation"
CURRENT_OPERATION="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.operation.sync}' 2>/dev/null || true)"
echo "CURRENT_OPERATION=${CURRENT_OPERATION:-none}"

kubectl patch application "$APP" -n "$ARGO_NS" --type merge -p '{
  "operation": {
    "sync": {
      "prune": true,
      "syncOptions": ["Prune=true", "CreateNamespace=true"]
    }
  }
}' || true

echo
echo "[7/12] Aguardar cache StatefulSets sumirem"
for attempt in $(seq 1 36); do
  sync="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  phase="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.operationState.phase}' 2>/dev/null || true)"
  msg="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.operationState.message}' 2>/dev/null || true)"

  echo "Tentativa $attempt/36 - sync=${sync:-N/A} health=${health:-N/A} phase=${phase:-N/A} msg=${msg:-N/A}"
  kubectl get statefulsets -n "$OBS_NS" | grep -E 'NAME|loki' || true
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true

  CACHE_STS_COUNT="$(kubectl get statefulsets -n "$OBS_NS" --no-headers 2>/dev/null | grep -E '^loki-(chunks-cache|results-cache)' | wc -l | tr -d ' ')"
  if [ "$CACHE_STS_COUNT" = "0" ]; then
    echo "OK: cache StatefulSets não existem mais."
    break
  fi

  sleep 10
done

echo
echo "[8/12] Remoção defensiva de caches antigos"
kubectl delete statefulset loki-chunks-cache loki-results-cache -n "$OBS_NS" --ignore-not-found || true
kubectl delete svc loki-chunks-cache loki-results-cache -n "$OBS_NS" --ignore-not-found || true
kubectl delete pod loki-chunks-cache-0 loki-results-cache-0 -n "$OBS_NS" --ignore-not-found --wait=false || true

sleep 25

echo
echo "[9/12] Reiniciar loki-0 para pegar estado final limpo"
kubectl delete pod loki-0 -n "$OBS_NS" --ignore-not-found --wait=false || true
sleep 30

echo
echo "[10/12] Estado após prune/restart"
kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
kubectl get statefulsets -n "$OBS_NS" | grep -E 'NAME|loki' || true
kubectl get svc -n "$OBS_NS" | grep -E 'NAME|loki' || true

echo
echo "[11/12] Logs do loki-0"
kubectl logs loki-0 -n "$OBS_NS" -c loki --tail=180 > "$TMP/loki-current.log" 2>&1 || true
kubectl logs loki-0 -n "$OBS_NS" -c loki --previous --tail=180 > "$TMP/loki-previous.log" 2>&1 || true

echo "---- current ----"
cat "$TMP/loki-current.log"
echo
echo "---- previous ----"
cat "$TMP/loki-previous.log"

{
  echo
  echo "## Estado após sync/prune"
  echo
  echo '```text'
  kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
  kubectl get statefulsets -n "$OBS_NS" | grep -E 'NAME|loki' || true
  kubectl get svc -n "$OBS_NS" | grep -E 'NAME|loki' || true
  echo '```'
  echo
  echo "## Logs loki-0 atuais"
  echo
  echo '```text'
  cat "$TMP/loki-current.log"
  echo '```'
  echo
  echo "## Logs loki-0 previous"
  echo
  echo '```text'
  cat "$TMP/loki-previous.log"
  echo '```'
} >> "$EVID"

echo
echo "[12/12] Resultado"
APP_SYNC="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
APP_HEALTH="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
CACHE_STS_COUNT="$(kubectl get statefulsets -n "$OBS_NS" --no-headers 2>/dev/null | grep -E '^loki-(chunks-cache|results-cache)' | wc -l | tr -d ' ')"
LOKI_STATUS="$(kubectl get pod loki-0 -n "$OBS_NS" --no-headers 2>/dev/null | awk '{print $3}' || true)"

echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"
echo "CACHE_STS_COUNT=$CACHE_STS_COUNT"
echo "LOKI_STATUS=$LOKI_STATUS"

{
  echo
  echo "## Resultado"
  echo
  echo "- Application Loki: \`$APP_SYNC/$APP_HEALTH\`"
  echo "- StatefulSets de cache restantes: \`$CACHE_STS_COUNT\`"
  echo "- Status do pod \`loki-0\`: \`$LOKI_STATUS\`"
} >> "$EVID"

if [ "$CACHE_STS_COUNT" != "0" ]; then
  echo "ERRO: caches ainda existem após sync/prune."
  exit 20
fi

if [ "$LOKI_STATUS" != "Running" ]; then
  echo "ERRO: caches removidos, mas Loki ainda não está Running. Usar logs desta evidência para próxima correção."
  exit 30
fi

echo "OK: Loki Running sem caches antigos."

echo
echo "============================================================"
echo "BLOCO 33.7 FINALIZADO"
echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"
echo "CACHE_STS_COUNT=$CACHE_STS_COUNT"
echo "LOKI_STATUS=$LOKI_STATUS"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
