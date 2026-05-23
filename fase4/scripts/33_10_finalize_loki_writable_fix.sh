#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
SCRIPT="$PHASE/scripts/33_10_finalize_loki_writable_fix.sh"
EVID="$PHASE/docs/evidencias/fase4-bloco33-10-loki-writable-final.md"
LOG="$PHASE/docs/evidencias/fase4-bloco33-10-loki-writable-final.log"
TMP="$PHASE/tmp/bloco33-10"

APP="observability-loki"
ARGO_NS="argocd"
OBS_NS="observability"
APP_FILE="fase4/gitops/apps/observability/loki-application.yaml"
BASE_VALUES="fase4/gitops/observability/values/loki-values.yaml"
OVERLAY_VALUES="fase4/gitops/observability/values/loki-lab-writable-values.yaml"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<'EOM'
# Fase 4 - BLOCO 33.10 - Loki com /var/loki writable

## Objetivo

Finalizar a correção do Loki para o AWS Academy Lab.

O diagnóstico anterior confirmou CrashLoopBackOff por tentativa de escrita em /var/loki com root filesystem somente leitura.

A correção mantém readOnlyRootFilesystem=true e adiciona um emptyDir montado em /var/loki.
EOM

{
  echo
  echo "Data: $(date)"
} >> "$EVID"

echo "[1/14] Estado inicial"
git status --short
git log --oneline --decorate -8
kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true

echo
echo "[2/14] Recriando overlay de values"
cat > "$OVERLAY_VALUES" <<'YAML'
# Phase 4 AWS Academy lab overlay.
# Keep the container root filesystem read-only, but provide a writable
# emptyDir at /var/loki because Loki's generated config uses /var/loki
# for path_prefix, chunks, rules and ruler WAL.
singleBinary:
  extraVolumes:
    - name: loki-var
      emptyDir: {}
  extraVolumeMounts:
    - name: loki-var
      mountPath: /var/loki
YAML

cat "$OVERLAY_VALUES"

echo
echo "[3/14] Corrigindo valueFiles no loki-application.yaml"
python3 - <<'PY'
from pathlib import Path
import sys

path = Path("fase4/gitops/apps/observability/loki-application.yaml")
text = path.read_text()

base = "          - $values/fase4/gitops/observability/values/loki-values.yaml"
overlay_correct = "          - $values/fase4/gitops/observability/values/loki-lab-writable-values.yaml"
overlay_wrong = "        - $values/fase4/gitops/observability/values/loki-lab-writable-values.yaml"

text = text.replace(overlay_wrong, overlay_correct)

if overlay_correct not in text:
    if base not in text:
        print("ERRO: linha base de valueFiles não encontrada.")
        sys.exit(20)
    text = text.replace(base, base + "\n" + overlay_correct, 1)

# Remover duplicatas mantendo a primeira ocorrência
lines = text.splitlines()
seen_overlay = False
out = []
for line in lines:
    if line.strip() == "- $values/fase4/gitops/observability/values/loki-lab-writable-values.yaml":
        if seen_overlay:
            continue
        seen_overlay = True
        out.append(overlay_correct)
    else:
        out.append(line)

path.write_text("\n".join(out) + "\n")
print("OK: loki-application.yaml corrigido.")
PY

echo
echo "[4/14] Conferindo trecho de valueFiles"
grep -nA8 -B4 'valueFiles' "$APP_FILE"

echo
echo "[5/14] Validando YAML via kubectl dry-run"
kubectl apply --dry-run=server -f "$APP_FILE" >/tmp/loki-app-dryrun.out
cat /tmp/loki-app-dryrun.out

echo
echo "[6/14] Validando Helm render com base + overlay"
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
  -f "$BASE_VALUES" \
  -f "$OVERLAY_VALUES" > "$TMP/loki-render.yaml"

grep -n 'mountPath: /var/loki' "$TMP/loki-render.yaml"
grep -n 'name: loki-var' "$TMP/loki-render.yaml"

CACHE_IN_RENDER="$(grep -E 'name: loki-(chunks-cache|results-cache)' "$TMP/loki-render.yaml" || true)"
if [ -n "$CACHE_IN_RENDER" ]; then
  echo "ERRO: render voltou a conter caches:"
  echo "$CACHE_IN_RENDER"
  exit 30
fi

echo "OK: render contém /var/loki writable e não contém caches."

echo
echo "[7/14] Scanner antes do commit"
python3 - <<'PY'
from pathlib import Path
import re
import sys

files = [
    Path("fase4/gitops/apps/observability/loki-application.yaml"),
    Path("fase4/gitops/observability/values/loki-values.yaml"),
    Path("fase4/gitops/observability/values/loki-lab-writable-values.yaml"),
    Path("fase4/scripts/33_10_finalize_loki_writable_fix.sh"),
    Path("fase4/docs/evidencias/fase4-bloco33-10-loki-writable-final.md"),
]

checks = [
    ("ToggleMaster API key real", re.compile(r"tm_key_[A-Za-z0-9]{20,}")),
    ("AWS access key id", re.compile(r"\b(?:AKIA|ASIA)[0-9A-Z]{16}\b")),
    ("Private key real", re.compile(r"-----BEGIN (?:RSA|OPENSSH|EC|DSA) PRIVATE KEY-----")),
]

findings = []
for path in files:
    if not path.exists():
        continue
    text = path.read_text(errors="ignore")
    for lineno, line in enumerate(text.splitlines(), start=1):
        if "re.compile" in line:
            continue
        for label, rx in checks:
            if rx.search(line):
                findings.append((str(path), lineno, label))

if findings:
    print("ERRO: possíveis segredos encontrados:")
    for path, lineno, label in findings:
        print(f"- {path}:{lineno}: {label}")
    sys.exit(10)

print("OK: nenhum segredo real encontrado.")
PY

echo
echo "[8/14] Registrando patch na evidência"
{
  echo
  echo "## Patch GitOps"
  echo
  echo '```diff'
  git diff -- "$APP_FILE" "$OVERLAY_VALUES" "$SCRIPT" "$EVID"
  echo '```'
  echo
  echo "## Validação local"
  echo
  echo '```text'
  echo "LOKI_VERSION=$LOKI_VERSION"
  echo "kubectl dry-run server OK"
  echo "Helm render OK com /var/loki writable e sem caches"
  echo '```'
} >> "$EVID"

echo
echo "[9/14] Commit e push da correção real"
git status --short

git add "$APP_FILE" "$OVERLAY_VALUES" "$SCRIPT" "$EVID"

if git diff --cached --quiet; then
  echo "ERRO: nenhum arquivo staged para commit."
  exit 40
fi

git commit -m "fix: mount writable var directory for loki"
git push origin main

echo
echo "[10/14] Aplicando Application atualizada"
kubectl apply -f "$APP_FILE"

echo
echo "[11/14] Refresh hard e sync/prune"
kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true
sleep 10

kubectl patch application "$APP" -n "$ARGO_NS" --type merge -p '{
  "operation": {
    "sync": {
      "prune": true,
      "syncOptions": ["Prune=true", "CreateNamespace=true", "ServerSideApply=true"]
    }
  }
}' || true

kubectl delete statefulset loki-chunks-cache loki-results-cache -n "$OBS_NS" --ignore-not-found || true
kubectl delete svc loki-chunks-cache loki-results-cache -n "$OBS_NS" --ignore-not-found || true
kubectl delete pod loki-chunks-cache-0 loki-results-cache-0 -n "$OBS_NS" --ignore-not-found --wait=false || true
kubectl delete pod loki-0 -n "$OBS_NS" --ignore-not-found --wait=false || true

echo
echo "[12/14] Aguardando Loki 2/2 Running"
for attempt in $(seq 1 60); do
  APP_SYNC="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  APP_HEALTH="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  LOKI_READY="$(kubectl get pod loki-0 -n "$OBS_NS" --no-headers 2>/dev/null | awk '{print $2}' || true)"
  LOKI_STATUS="$(kubectl get pod loki-0 -n "$OBS_NS" --no-headers 2>/dev/null | awk '{print $3}' || true)"
  CACHE_STS_COUNT="$(kubectl get sts -n "$OBS_NS" --no-headers 2>/dev/null | awk '/^loki-(chunks-cache|results-cache)/ {c++} END {print c+0}')"

  echo "Tentativa $attempt/60 - app=$APP_SYNC/$APP_HEALTH loki=$LOKI_READY/$LOKI_STATUS caches=$CACHE_STS_COUNT"
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true

  if [ "$LOKI_READY" = "2/2" ] && [ "$LOKI_STATUS" = "Running" ] && [ "$CACHE_STS_COUNT" = "0" ]; then
    echo "OK: Loki Running sem caches."
    break
  fi

  sleep 10
done

echo
echo "[13/14] Validando endpoint /ready"
kubectl logs loki-0 -n "$OBS_NS" -c loki --tail=180 > "$TMP/loki-current.log" 2>&1 || true

kubectl run loki-ready-test \
  -n "$OBS_NS" \
  --rm \
  -i \
  --restart=Never \
  --image=curlimages/curl:8.10.1 \
  --command -- sh -c 'curl -sS http://loki.observability.svc.cluster.local:3100/ready' \
  > "$TMP/loki-ready.txt" 2>&1 || true

cat "$TMP/loki-ready.txt"

APP_SYNC="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
APP_HEALTH="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
LOKI_READY="$(kubectl get pod loki-0 -n "$OBS_NS" --no-headers 2>/dev/null | awk '{print $2}' || true)"
LOKI_STATUS="$(kubectl get pod loki-0 -n "$OBS_NS" --no-headers 2>/dev/null | awk '{print $3}' || true)"
CACHE_STS_COUNT="$(kubectl get sts -n "$OBS_NS" --no-headers 2>/dev/null | awk '/^loki-(chunks-cache|results-cache)/ {c++} END {print c+0}')"

echo
echo "[14/14] Registrando resultado final"
{
  echo
  echo "## Resultado runtime"
  echo
  echo '```text'
  echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"
  echo "LOKI_READY=$LOKI_READY"
  echo "LOKI_STATUS=$LOKI_STATUS"
  echo "CACHE_STS_COUNT=$CACHE_STS_COUNT"
  echo '```'
  echo
  echo "## Estado final"
  echo
  echo '```text'
  kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
  kubectl get sts -n "$OBS_NS" | grep -E 'NAME|loki' || true
  kubectl get svc -n "$OBS_NS" | grep -E 'NAME|loki' || true
  echo '```'
  echo
  echo "## Loki ready"
  echo
  echo '```text'
  cat "$TMP/loki-ready.txt"
  echo '```'
  echo
  echo "## Logs Loki"
  echo
  echo '```text'
  cat "$TMP/loki-current.log"
  echo '```'
} >> "$EVID"

if [ "$CACHE_STS_COUNT" != "0" ]; then
  echo "ERRO: caches ainda existem."
  exit 50
fi

if [ "$LOKI_READY" != "2/2" ] || [ "$LOKI_STATUS" != "Running" ]; then
  echo "ERRO: Loki ainda não está 2/2 Running."
  exit 51
fi

if ! grep -qi "ready" "$TMP/loki-ready.txt"; then
  echo "ERRO: /ready do Loki não retornou ready."
  exit 52
fi

echo
echo "============================================================"
echo "BLOCO 33.10 FINALIZADO"
echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"
echo "LOKI_READY=$LOKI_READY"
echo "LOKI_STATUS=$LOKI_STATUS"
echo "CACHE_STS_COUNT=$CACHE_STS_COUNT"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
