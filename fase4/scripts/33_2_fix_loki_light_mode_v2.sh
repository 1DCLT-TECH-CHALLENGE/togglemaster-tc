#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
SCRIPT="$PHASE/scripts/33_2_fix_loki_light_mode_v2.sh"
EVID="$PHASE/docs/evidencias/fase4-bloco33-2-loki-light-mode-v2.md"
LOG="$PHASE/docs/evidencias/fase4-bloco33-2-loki-light-mode-v2.log"
TMP="$PHASE/tmp/bloco33-2"

VALUES="fase4/gitops/observability/values/loki-values.yaml"
APP_FILE="fase4/gitops/apps/observability/loki-application.yaml"
APP="observability-loki"
ARGO_NS="argocd"
OBS_NS="observability"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 33.2 - Loki em modo leve

Data: $(date)

## Objetivo

Corrigir definitivamente a configuração do Loki para um perfil leve no AWS Academy, removendo caches/memcached que causaram pressão de memória/pods e impediam a Application de ficar Healthy.

Este bloco também corrige o erro de parsing de versão Helm observado no BLOCO 33.1.

EOM

echo "[1/11] Limpando artefatos falhos não versionados dos blocos 33 anteriores"
for f in \
  "fase4/scripts/33_apply_loki_promtail_argocd.sh" \
  "fase4/docs/evidencias/fase4-bloco33-loki-promtail-argocd.md" \
  "fase4/scripts/33_1_fix_loki_light_mode.sh" \
  "fase4/docs/evidencias/fase4-bloco33-1-loki-light-mode-fix.md"
do
  if [ -e "$f" ] && ! git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    echo "Removendo artefato não versionado: $f"
    rm -f "$f"
  fi
done

echo
echo "[2/11] Estado inicial"
git status --short
kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
kubectl get events -n "$OBS_NS" --sort-by=.lastTimestamp | tail -60 || true

{
  echo
  echo "## Estado antes da correção"
  echo
  echo '```text'
  git status --short
  kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
  echo '```'
} >> "$EVID"

echo
echo "[3/11] Coletando logs atuais do Loki"
{
  echo
  echo "## Logs Loki antes da correção"
  echo
  echo '```text'
  kubectl logs loki-0 -n "$OBS_NS" -c loki --tail=120 || true
  echo
  echo "--- previous ---"
  kubectl logs loki-0 -n "$OBS_NS" -c loki --previous --tail=120 || true
  echo '```'
} >> "$EVID"

echo
echo "[4/11] Aplicando patch idempotente no loki-values.yaml"
test -f "$VALUES"
test -f "$APP_FILE"

python3 - <<'PY'
from pathlib import Path
import re

path = Path("fase4/gitops/observability/values/loki-values.yaml")
text = path.read_text()

# Remove blocos antigos do perfil leve, se existirem.
text = re.sub(
    r"\n# Phase 4 AWS Academy lightweight profile\.\n# Disable Loki memcached caches to avoid Pending pods and memory pressure\.\nchunksCache:\n  enabled: false\n\nresultsCache:\n  enabled: false\n",
    "\n",
    text,
    flags=re.MULTILINE,
)

# Remove blocos chunksCache/resultsCache simples, se já existirem.
for key in ["chunksCache", "resultsCache"]:
    text = re.sub(rf"\n{key}:\n(?:  .*\n)+", "\n", text)

addition = """
# Phase 4 AWS Academy lightweight profile.
# Disable Loki memcached caches to avoid Pending pods and memory pressure.
chunksCache:
  enabled: false

resultsCache:
  enabled: false
"""

text = text.rstrip() + "\n" + addition + "\n"
path.write_text(text)
PY

echo
echo "Diff atual:"
git diff -- "$VALUES"

{
  echo
  echo "## Patch aplicado"
  echo
  echo '```diff'
  git diff -- "$VALUES"
  echo '```'
} >> "$EVID"

echo
echo "[5/11] Extraindo versão Helm corretamente"
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

echo
echo "[6/11] Validando Helm template sem caches"
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1

helm template loki grafana/loki \
  --version "$LOKI_VERSION" \
  --namespace "$OBS_NS" \
  -f "$VALUES" > "$TMP/loki-render.yaml"

if grep -qE 'name: loki-(chunks-cache|results-cache)' "$TMP/loki-render.yaml"; then
  echo "ERRO: render ainda contém recursos de cache."
  grep -nE 'name: loki-(chunks-cache|results-cache)' "$TMP/loki-render.yaml" || true
  exit 20
fi

echo "OK: render do Loki não contém chunks-cache/results-cache."

echo
echo "[7/11] Scanner simples antes do commit"
python3 - <<'PY'
from pathlib import Path
import re
import sys

files = [
    Path("fase4/gitops/observability/values/loki-values.yaml"),
    Path("fase4/scripts/33_2_fix_loki_light_mode_v2.sh"),
    Path("fase4/docs/evidencias/fase4-bloco33-2-loki-light-mode-v2.md"),
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
echo "[8/11] Commit e push da correção GitOps"
git add "$VALUES" "$SCRIPT" "$EVID"

if git diff --cached --quiet; then
  echo "ERRO: nenhum arquivo staged para commit."
  exit 30
fi

git commit -m "fix: disable loki caches for phase 4 lab"
git push origin main

echo
echo "[9/11] Removendo recursos antigos de cache e reiniciando Loki"
kubectl delete statefulset loki-chunks-cache loki-results-cache -n "$OBS_NS" --ignore-not-found || true
kubectl delete svc loki-chunks-cache loki-results-cache -n "$OBS_NS" --ignore-not-found || true
kubectl delete pod loki-0 -n "$OBS_NS" --ignore-not-found --wait=false || true

echo
echo "[10/11] Forçando refresh hard e aguardando Loki Healthy"
kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true

for attempt in $(seq 1 60); do
  sync="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  echo "Tentativa $attempt/60 - $APP sync=${sync:-N/A} health=${health:-N/A}"
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true

  if [ "$sync" = "Synced" ] && [ "$health" = "Healthy" ]; then
    echo "$APP Synced/Healthy"
    break
  fi

  sleep 10
done

APP_SYNC="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
APP_HEALTH="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"

if [ "$APP_SYNC" != "Synced" ] || [ "$APP_HEALTH" != "Healthy" ]; then
  echo "ERRO: Loki ainda não ficou Synced/Healthy."
  kubectl describe application "$APP" -n "$ARGO_NS" || true
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
  kubectl logs loki-0 -n "$OBS_NS" -c loki --tail=160 || true
  exit 40
fi

echo
echo "[11/11] Validando Loki /ready e registrando resultado"
kubectl run loki-ready-test \
  -n "$OBS_NS" \
  --rm \
  -i \
  --restart=Never \
  --image=curlimages/curl:8.10.1 \
  --command -- sh -c 'curl -sS http://loki.observability.svc.cluster.local:3100/ready' \
  > "$TMP/loki-ready.txt"

cat "$TMP/loki-ready.txt"

{
  echo
  echo "## Resultado"
  echo
  echo "- Loki Application: \`$APP_SYNC/$APP_HEALTH\`"
  echo "- Caches/memcached desabilitados."
  echo "- Recursos antigos de cache removidos do cluster."
  echo "- Loki validado via endpoint \`/ready\`."
  echo
  echo "### Estado final"
  echo
  echo '```text'
  kubectl get application "$APP" -n "$ARGO_NS" -o wide
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|loki' || true
  echo '```'
  echo
  echo "### Loki ready"
  echo
  echo '```text'
  cat "$TMP/loki-ready.txt"
  echo '```'
} >> "$EVID"

echo
echo "============================================================"
echo "BLOCO 33.2 FINALIZADO"
echo "APP_STATUS=$APP_SYNC/$APP_HEALTH"
echo "Loki estabilizado em modo leve."
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
