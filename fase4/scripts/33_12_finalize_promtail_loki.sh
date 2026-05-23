#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
SCRIPT="$PHASE/scripts/33_12_finalize_promtail_loki.sh"
EVID="$PHASE/docs/evidencias/fase4-bloco33-12-promtail-logs-loki.md"
LOG="$PHASE/docs/evidencias/fase4-bloco33-12-promtail-logs-loki.log"
TMP="$PHASE/tmp/bloco33-12c"

ARGO_NS="argocd"
OBS_NS="observability"
APP_NS="togglemaster"
PROMTAIL_APP="observability-promtail"
LOKI_APP="observability-loki"
LOCAL_PORT="13100"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cleanup() {
  if [ -n "${PF_PID:-}" ]; then
    echo
    echo "Cleanup: encerrando port-forward Loki..."
    kill "$PF_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

cat > "$EVID" <<'EOM'
# Fase 4 - BLOCO 33.12 - Promtail e logs reais no Loki

## Objetivo

Validar que o Promtail coleta logs reais do namespace togglemaster e envia ao Loki.

Esta evidência fecha a cadeia:

pod no namespace togglemaster -> Promtail -> Loki -> consulta Loki API.
EOM

{
  echo
  echo "Data: $(date)"
} >> "$EVID"

echo "[1/13] Estado inicial"
git status --short
git log --oneline --decorate -8
kubectl get application "$LOKI_APP" "$PROMTAIL_APP" -n "$ARGO_NS" -o wide || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki|promtail' || true
kubectl get ds -n "$OBS_NS" | grep -E 'NAME|promtail' || true

echo
echo "[2/13] Validando Loki e Promtail Healthy"
LOKI_SYNC="$(kubectl get application "$LOKI_APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
LOKI_HEALTH="$(kubectl get application "$LOKI_APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
PROMTAIL_SYNC="$(kubectl get application "$PROMTAIL_APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
PROMTAIL_HEALTH="$(kubectl get application "$PROMTAIL_APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"

echo "LOKI_APP=$LOKI_SYNC/$LOKI_HEALTH"
echo "PROMTAIL_APP=$PROMTAIL_SYNC/$PROMTAIL_HEALTH"

if [ "$LOKI_SYNC" != "Synced" ] || [ "$LOKI_HEALTH" != "Healthy" ]; then
  echo "ERRO: Loki não está Synced/Healthy."
  exit 10
fi

if [ "$PROMTAIL_SYNC" != "Synced" ] || [ "$PROMTAIL_HEALTH" != "Healthy" ]; then
  echo "ERRO: Promtail não está Synced/Healthy."
  exit 11
fi

echo
echo "[3/13] Validando DaemonSet Promtail"
PROMTAIL_DESIRED="$(kubectl get ds promtail -n "$OBS_NS" -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null || echo 0)"
PROMTAIL_READY="$(kubectl get ds promtail -n "$OBS_NS" -o jsonpath='{.status.numberReady}' 2>/dev/null || echo 0)"
NODE_READY_COUNT="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 == "Ready" {c++} END {print c+0}')"

echo "PROMTAIL_DESIRED=$PROMTAIL_DESIRED"
echo "PROMTAIL_READY=$PROMTAIL_READY"
echo "NODE_READY_COUNT=$NODE_READY_COUNT"

if [ "$PROMTAIL_READY" != "$PROMTAIL_DESIRED" ]; then
  echo "ERRO: Promtail ainda não está Ready em todos os nodes desejados."
  exit 12
fi

echo
echo "[4/13] Limpando pods temporários antigos de teste"
kubectl delete pod promtail-log-test -n "$APP_NS" --ignore-not-found --grace-period=0 --force || true
kubectl delete pod -n "$APP_NS" -l tc=promtail-log-test --ignore-not-found --grace-period=0 --force || true
sleep 8

echo
echo "[5/13] Abrindo port-forward local para Loki"
pkill -f "kubectl.*port-forward.*svc/loki.*${LOCAL_PORT}:3100" >/dev/null 2>&1 || true
kubectl -n "$OBS_NS" port-forward svc/loki "${LOCAL_PORT}:3100" > "$TMP/loki-port-forward.log" 2>&1 &
PF_PID=$!

sleep 5

if ! kill -0 "$PF_PID" >/dev/null 2>&1; then
  echo "ERRO: port-forward do Loki não ficou ativo."
  cat "$TMP/loki-port-forward.log" || true
  exit 20
fi

python3 - <<'PY' > "fase4/tmp/bloco33-12c/loki-ready.txt"
import urllib.request
print(urllib.request.urlopen("http://localhost:13100/ready", timeout=10).read().decode())
PY

cat "$TMP/loki-ready.txt"

if ! grep -qi "ready" "$TMP/loki-ready.txt"; then
  echo "ERRO: Loki /ready não retornou ready."
  exit 21
fi

echo
echo "[6/13] Gerando log real no namespace togglemaster"
MARKER="TOGGLEMASTER_PROMTAIL_FINAL_$(date +%s)"
POD_NAME="promtail-log-test-$(date +%s)"

echo "MARKER=$MARKER" | tee "$TMP/marker.txt"
echo "POD_NAME=$POD_NAME" | tee "$TMP/pod-name.txt"

kubectl run "$POD_NAME" \
  -n "$APP_NS" \
  --labels="tc=promtail-log-test" \
  --restart=Never \
  --image=busybox:1.36 \
  --command -- sh -c "echo ${MARKER}; sleep 120"

kubectl wait --for=condition=Ready "pod/$POD_NAME" -n "$APP_NS" --timeout=120s || true
kubectl logs "$POD_NAME" -n "$APP_NS" > "$TMP/promtail-log-test.log" 2>&1 || true
cat "$TMP/promtail-log-test.log"

if ! grep -q "$MARKER" "$TMP/promtail-log-test.log"; then
  echo "ERRO: marker não apareceu no log do pod de teste."
  kubectl describe pod "$POD_NAME" -n "$APP_NS" || true
  exit 30
fi

echo
echo "[7/13] Aguardando ingestão no Loki"
sleep 45

echo
echo "[8/13] Consultando Loki via port-forward local"
python3 - "$MARKER" > "$TMP/loki-query.json" <<'PY'
import json
import sys
import time
import urllib.parse
import urllib.request

marker = sys.argv[1]
start_ns = (int(time.time()) - 900) * 1_000_000_000
end_ns = (int(time.time()) + 60) * 1_000_000_000

query = f'{{namespace="togglemaster"}} |= "{marker}"'
params = urllib.parse.urlencode({
    "query": query,
    "start": str(start_ns),
    "end": str(end_ns),
    "limit": "20",
})

url = f"http://localhost:13100/loki/api/v1/query_range?{params}"
body = urllib.request.urlopen(url, timeout=20).read().decode()
print(body)
PY

cat "$TMP/loki-query.json"

echo
echo "[9/13] Validando resposta JSON do Loki"
python3 - "$TMP/loki-query.json" "$MARKER" > "$TMP/loki-query-validation.txt" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
marker = sys.argv[2]
text = path.read_text(errors="ignore").strip()
data = json.loads(text)

status = data.get("status")
result = data.get("data", {}).get("result", [])
found = marker in text

print(f"LOKI_QUERY_STATUS={status}")
print(f"LOKI_MARKER_FOUND={str(found).lower()}")
print(f"LOKI_RESULT_STREAMS={len(result)}")

if status != "success":
    raise SystemExit(2)
if not found:
    raise SystemExit(3)
PY

cat "$TMP/loki-query-validation.txt"

echo
echo "[10/13] Limpando pod de teste"
kubectl delete pod "$POD_NAME" -n "$APP_NS" --ignore-not-found --wait=false || true

echo
echo "[11/13] Estado final"
kubectl get application "$LOKI_APP" "$PROMTAIL_APP" -n "$ARGO_NS" -o wide || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki|promtail' || true
kubectl get ds -n "$OBS_NS" | grep -E 'NAME|promtail' || true

echo
echo "[12/13] Registrando evidência"
{
  echo
  echo "## Resultado"
  echo
  echo "- Loki Application: \`$LOKI_SYNC/$LOKI_HEALTH\`"
  echo "- Promtail Application: \`$PROMTAIL_SYNC/$PROMTAIL_HEALTH\`"
  echo "- Promtail Desired/Ready: \`$PROMTAIL_DESIRED/$PROMTAIL_READY\`"
  echo "- Nodes Ready: \`$NODE_READY_COUNT\`"
  echo "- Pod de teste: \`$POD_NAME\`"
  echo "- Log real emitido no namespace \`$APP_NS\`."
  echo "- Log real encontrado via consulta Loki API."
  echo
  echo "## Estado das Applications"
  echo
  echo '```text'
  kubectl get application "$LOKI_APP" "$PROMTAIL_APP" -n "$ARGO_NS" -o wide || true
  echo '```'
  echo
  echo "## Pods Loki e Promtail"
  echo
  echo '```text'
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki|promtail' || true
  echo '```'
  echo
  echo "## DaemonSet Promtail"
  echo
  echo '```text'
  kubectl get ds promtail -n "$OBS_NS" -o wide || true
  echo '```'
  echo
  echo "## Loki ready"
  echo
  echo '```text'
  cat "$TMP/loki-ready.txt"
  echo '```'
  echo
  echo "## Log real emitido"
  echo
  echo '```text'
  cat "$TMP/promtail-log-test.log"
  echo '```'
  echo
  echo "## Validação da consulta Loki"
  echo
  echo '```text'
  cat "$TMP/loki-query-validation.txt"
  echo '```'
  echo
  echo "## Resposta Loki"
  echo
  echo '```json'
  cat "$TMP/loki-query.json"
  echo
  echo '```'
} >> "$EVID"

echo
echo "[13/13] Resultado"
echo "PROMTAIL_APP=$PROMTAIL_SYNC/$PROMTAIL_HEALTH"
echo "PROMTAIL_DESIRED_READY=$PROMTAIL_DESIRED/$PROMTAIL_READY"
echo "LOKI_MARKER_FOUND=true"

echo
echo "============================================================"
echo "BLOCO 33.12C FINALIZADO"
echo "PROMTAIL_APP=$PROMTAIL_SYNC/$PROMTAIL_HEALTH"
echo "PROMTAIL_DESIRED_READY=$PROMTAIL_DESIRED/$PROMTAIL_READY"
echo "LOKI_MARKER_FOUND=true"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
