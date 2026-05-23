#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md"
LOG="$PHASE/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.log"
TMP="$PHASE/tmp/bloco33-8"

APP="observability-loki"
ARGO_NS="argocd"
OBS_NS="observability"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 33.8 - Diagnóstico do CrashLoop do Loki

Data: $(date)

## Objetivo

Diagnosticar o erro real do container \`loki\` após a remoção/prune dos caches antigos.

Este bloco não altera recursos Kubernetes, não aplica manifests e não reinicia pods.

EOM

echo "[1/10] Estado geral"
git status --short
git log --oneline --decorate -8
kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
kubectl get application -n "$ARGO_NS" || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
kubectl get statefulsets -n "$OBS_NS" | grep -E 'NAME|loki' || true
kubectl get svc -n "$OBS_NS" | grep -E 'NAME|loki' || true

{
  echo
  echo "## Estado geral"
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
echo "[2/10] Descrever pod loki-0"
kubectl describe pod loki-0 -n "$OBS_NS" > "$TMP/loki-describe.txt" 2>&1 || true
tail -180 "$TMP/loki-describe.txt"

echo
echo "[3/10] Logs atuais e previous do container loki"
kubectl logs loki-0 -n "$OBS_NS" -c loki --tail=240 > "$TMP/loki-current.log" 2>&1 || true
kubectl logs loki-0 -n "$OBS_NS" -c loki --previous --tail=240 > "$TMP/loki-previous.log" 2>&1 || true

echo "---- current ----"
cat "$TMP/loki-current.log"
echo
echo "---- previous ----"
cat "$TMP/loki-previous.log"

echo
echo "[4/10] Logs do sidecar loki-sc-rules"
kubectl logs loki-0 -n "$OBS_NS" -c loki-sc-rules --tail=120 > "$TMP/loki-sidecar.log" 2>&1 || true
cat "$TMP/loki-sidecar.log"

echo
echo "[5/10] ConfigMaps Loki"
kubectl get cm -n "$OBS_NS" | grep -E 'NAME|loki' || true

kubectl get cm loki -n "$OBS_NS" -o yaml > "$TMP/cm-loki.yaml" 2>&1 || true
kubectl get cm loki-runtime -n "$OBS_NS" -o yaml > "$TMP/cm-loki-runtime.yaml" 2>&1 || true

echo "---- cm loki relevant lines ----"
grep -nE 'auth_enabled|schema|storage|filesystem|object_store|path_prefix|common|replication|limits|ruler|compactor|boltdb|tsdb|memberlist|ring|address|port|grpc' "$TMP/cm-loki.yaml" || true

echo
echo "[6/10] StatefulSet Loki"
kubectl get sts loki -n "$OBS_NS" -o yaml > "$TMP/sts-loki.yaml" 2>&1 || true

echo "---- sts loki relevant lines ----"
grep -nE 'image:|args:|command:|mountPath:|name:|containerPort:|readinessProbe|livenessProbe|resources:|requests:|limits:' "$TMP/sts-loki.yaml" | head -220 || true

echo
echo "[7/10] Eventos recentes observability"
kubectl get events -n "$OBS_NS" --sort-by=.lastTimestamp | tail -100 > "$TMP/events-tail.txt" 2>&1 || true
cat "$TMP/events-tail.txt"

echo
echo "[8/10] Resumo automático dos erros prováveis"
python3 - <<'PY' > "fase4/tmp/bloco33-8/error-summary.txt"
from pathlib import Path
import re

files = [
    ("current", Path("fase4/tmp/bloco33-8/loki-current.log")),
    ("previous", Path("fase4/tmp/bloco33-8/loki-previous.log")),
    ("describe", Path("fase4/tmp/bloco33-8/loki-describe.txt")),
]

patterns = [
    r"(?i)error",
    r"(?i)failed",
    r"(?i)panic",
    r"(?i)fatal",
    r"(?i)permission denied",
    r"(?i)invalid",
    r"(?i)mkdir",
    r"(?i)no such file",
    r"(?i)schema",
    r"(?i)storage",
    r"(?i)memberlist",
    r"(?i)address",
    r"(?i)config",
]

for label, path in files:
    print(f"### {label}")
    text = path.read_text(errors="ignore") if path.exists() else ""
    matched = []
    for line in text.splitlines():
        if any(re.search(p, line) for p in patterns):
            matched.append(line)
    if matched:
        for line in matched[-80:]:
            print(line)
    else:
        print("Nenhuma linha de erro encontrada pelos padrões.")
    print()
PY

cat "$TMP/error-summary.txt"

echo
echo "[9/10] Registrar evidência"
{
  echo
  echo "## Describe loki-0"
  echo
  echo '```text'
  tail -220 "$TMP/loki-describe.txt"
  echo '```'
  echo
  echo "## Logs container loki - atual"
  echo
  echo '```text'
  cat "$TMP/loki-current.log"
  echo '```'
  echo
  echo "## Logs container loki - previous"
  echo
  echo '```text'
  cat "$TMP/loki-previous.log"
  echo '```'
  echo
  echo "## Logs sidecar loki-sc-rules"
  echo
  echo '```text'
  cat "$TMP/loki-sidecar.log"
  echo '```'
  echo
  echo "## ConfigMap Loki - linhas relevantes"
  echo
  echo '```text'
  grep -nE 'auth_enabled|schema|storage|filesystem|object_store|path_prefix|common|replication|limits|ruler|compactor|boltdb|tsdb|memberlist|ring|address|port|grpc' "$TMP/cm-loki.yaml" || true
  echo '```'
  echo
  echo "## StatefulSet Loki - linhas relevantes"
  echo
  echo '```text'
  grep -nE 'image:|args:|command:|mountPath:|name:|containerPort:|readinessProbe|livenessProbe|resources:|requests:|limits:' "$TMP/sts-loki.yaml" | head -220 || true
  echo '```'
  echo
  echo "## Eventos recentes"
  echo
  echo '```text'
  cat "$TMP/events-tail.txt"
  echo '```'
  echo
  echo "## Resumo automático"
  echo
  echo '```text'
  cat "$TMP/error-summary.txt"
  echo '```'
} >> "$EVID"

echo
echo "[10/10] Resultado"
LOKI_STATUS="$(kubectl get pod loki-0 -n "$OBS_NS" --no-headers 2>/dev/null | awk '{print $3}' || true)"
APP_SYNC="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
APP_HEALTH="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"

echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"
echo "LOKI_STATUS=$LOKI_STATUS"
echo "Evidência: $EVID"
echo "Log: $LOG"

{
  echo
  echo "## Resultado"
  echo
  echo "- Application Loki: \`$APP_SYNC/$APP_HEALTH\`"
  echo "- Status do pod loki-0: \`$LOKI_STATUS\`"
  echo "- Próximo passo: aplicar correção específica baseada nos logs acima."
} >> "$EVID"

echo
echo "============================================================"
echo "BLOCO 33.8 FINALIZADO"
echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"
echo "LOKI_STATUS=$LOKI_STATUS"
echo "Terminal continua vivo."
echo "============================================================"
