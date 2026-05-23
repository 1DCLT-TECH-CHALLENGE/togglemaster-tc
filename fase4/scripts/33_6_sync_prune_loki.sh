#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco33-6-loki-sync-prune.md"
LOG="$PHASE/docs/evidencias/fase4-bloco33-6-loki-sync-prune.log"
TMP="$PHASE/tmp/bloco33-6"

APP="observability-loki"
ARGO_NS="argocd"
OBS_NS="observability"
VALUES="fase4/gitops/observability/values/loki-values.yaml"
APP_FILE="fase4/gitops/apps/observability/loki-application.yaml"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 33.6 - Sync/prune do Loki no ArgoCD

Data: $(date)

## Objetivo

Forçar o ArgoCD a aplicar o estado GitOps atual do Loki, com prune dos recursos antigos de cache/memcached, e diagnosticar o CrashLoop do \`loki-0\`.

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
echo "[2/12] Confirmando values locais sem caches"
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
  echo "ERRO: render local ainda contém caches. Parando."
  grep -nE 'name: loki-(chunks-cache|results-cache)' "$TMP/loki-render.yaml" || true
  exit 10
fi

echo "OK: render local não contém chunks-cache/results-cache."

{
  echo
  echo "## Render local"
  echo
  echo '```text'
  echo "LOKI_VERSION=$LOKI_VERSION"
  echo "Render local não contém chunks-cache/results-cache."
  echo '```'
} >> "$EVID"

echo
echo "[3/12] Inspecionando Application source/syncPolicy"
kubectl get application "$APP" -n "$ARGO_NS" -o yaml > "$TMP/app-before.yaml"

python3 - <<'PY' "$TMP/app-before.yaml"
import sys, yaml
from pathlib import Path

data = yaml.safe_load(Path(sys.argv[1]).read_text())
spec = data.get("spec", {})
source = spec.get("source", {})
sync_policy = spec.get("syncPolicy", {})
status = data.get("status", {})

print("Application source:")
print(f"- repoURL={source.get('repoURL')}")
print(f"- targetRevision={source.get('targetRevision')}")
print(f"- path={source.get('path')}")
print(f"- chart={source.get('chart')}")
print("Application syncPolicy:")
print(sync_policy)
print("Application status:")
print(f"- sync={status.get('sync', {}).get('status')}")
print(f"- health={status.get('health', {}).get('status')}")
print(f"- revision={status.get('sync', {}).get('revision')}")
PY

echo
echo "[4/12] Recursos OutOfSync/gerenciados pelo ArgoCD"
kubectl get application "$APP" -n "$ARGO_NS" \
  -o jsonpath='{range .status.resources[*]}{.kind}{"\t"}{.namespace}{"\t"}{.name}{"\t"}{.status}{"\t"}{.health.status}{"\n"}{end}' \
  | sort || true

{
  echo
  echo "## Recursos gerenciados antes do sync/prune"
  echo
  echo '```text'
  kubectl get application "$APP" -n "$ARGO_NS" \
    -o jsonpath='{range .status.resources[*]}{.kind}{"\t"}{.namespace}{"\t"}{.name}{"\t"}{.status}{"\t"}{.health.status}{"\n"}{end}' \
    | sort || true
  echo '```'
} >> "$EVID"

echo
echo "[5/12] Forçando refresh hard"
kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true
sleep 20

echo
echo "[6/12] Tentando sync/prune via ArgoCD CLI, se disponível"
if command -v argocd >/dev/null 2>&1; then
  echo "argocd CLI encontrado."
  set +e
  argocd app sync "$APP" --prune --grpc-web
  ARGOCD_SYNC_RC=$?
  set -e
  echo "ARGOCD_SYNC_RC=$ARGOCD_SYNC_RC"
else
  echo "argocd CLI não encontrado; usando patch operation no Application."
  ARGOCD_SYNC_RC=127
fi

echo
echo "[7/12] Se CLI não sincronizou, solicitar sync via Application operation"
if [ "${ARGOCD_SYNC_RC:-127}" -ne 0 ]; then
  kubectl patch application "$APP" -n "$ARGO_NS" --type merge -p '{
    "operation": {
      "sync": {
        "prune": true,
        "syncOptions": ["Prune=true", "CreateNamespace=true"]
      }
    }
  }' || true
fi

echo
echo "[8/12] Aguardando sync/prune refletir"
for attempt in $(seq 1 60); do
  sync="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  phase="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.operationState.phase}' 2>/dev/null || true)"
  msg="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.operationState.message}' 2>/dev/null || true)"

  echo "Tentativa $attempt/60 - sync=${sync:-N/A} health=${health:-N/A} phase=${phase:-N/A} msg=${msg:-N/A}"
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
  kubectl get statefulsets -n "$OBS_NS" | grep -E 'NAME|loki' || true

  if ! kubectl get statefulset loki-chunks-cache -n "$OBS_NS" >/dev/null 2>&1 \
     && ! kubectl get statefulset loki-results-cache -n "$OBS_NS" >/dev/null 2>&1; then
    echo "OK: StatefulSets de cache não existem mais."
    break
  fi

  sleep 10
done

echo
echo "[9/12] Remoção final defensiva dos caches antigos, se ainda existirem"
kubectl delete statefulset loki-chunks-cache loki-results-cache -n "$OBS_NS" --ignore-not-found || true
kubectl delete svc loki-chunks-cache loki-results-cache -n "$OBS_NS" --ignore-not-found || true
kubectl delete pod loki-chunks-cache-0 loki-results-cache-0 -n "$OBS_NS" --ignore-not-found --wait=false || true

sleep 20

echo
echo "[10/12] Estado Loki após prune"
kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
kubectl get statefulsets -n "$OBS_NS" | grep -E 'NAME|loki' || true
kubectl get svc -n "$OBS_NS" | grep -E 'NAME|loki' || true

echo
echo "[11/12] Logs do loki-0"
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
  kubectl logs loki-0 -n "$OBS_NS" -c loki --tail=200 || true
  echo '```'
  echo
  echo "## Logs loki-0 previous"
  echo
  echo '```text'
  kubectl logs loki-0 -n "$OBS_NS" -c loki --previous --tail=200 || true
  echo '```'
} >> "$EVID"

kubectl logs loki-0 -n "$OBS_NS" -c loki --tail=120 || true

echo
echo "[12/12] Resultado parcial"
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
  echo "ERRO: caches removidos, mas Loki ainda não está Running. Logs foram registrados para próxima correção."
  exit 30
fi

echo
echo "============================================================"
echo "BLOCO 33.6 FINALIZADO"
echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"
echo "CACHE_STS_COUNT=$CACHE_STS_COUNT"
echo "LOKI_STATUS=$LOKI_STATUS"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
