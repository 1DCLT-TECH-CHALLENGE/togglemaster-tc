#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md"
LOG="$PHASE/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.log"
TMP="$PHASE/tmp/bloco35-0"

ARGO_NS="argocd"
APP_NS="togglemaster"
OBS_NS="observability"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<'EOM'
# Fase 4 - BLOCO 35.0 - Inventário APM/tracing

## Objetivo

Inventariar o estado atual da instrumentação, dos serviços e dos manifests antes de implementar APM/tracing real.

Este bloco não altera recursos Kubernetes, não aplica manifests e não modifica código de aplicação.
EOM

{
  echo
  echo "Data: $(date)"
} >> "$EVID"

echo "[1/12] Estado Git e últimos commits"
git status --short
git log --oneline --decorate -12

echo
echo "[2/12] Applications ArgoCD"
kubectl get application -n "$ARGO_NS" -o wide || true

echo
echo "[3/12] Workloads togglemaster"
kubectl get deploy,svc,pods -n "$APP_NS" -o wide || true

echo
echo "[4/12] Workloads observability relevantes"
kubectl get application observability-otel-collector observability-loki observability-promtail observability-kube-prometheus-stack -n "$ARGO_NS" -o wide || true
kubectl get deploy,svc,pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel-collector|loki|promtail|grafana|prometheus' || true

echo
echo "[5/12] Variáveis dos Deployments ToggleMaster"
for dep in $(kubectl get deploy -n "$APP_NS" --no-headers 2>/dev/null | awk '{print $1}' | sort); do
  echo
  echo "---- deployment/$dep ----"
  kubectl get deploy "$dep" -n "$APP_NS" -o jsonpath='{range .spec.template.spec.containers[*]}container={.name} image={.image}{"\n"}{range .env[*]}env:{.name}={.value}{"\n"}{end}{range .envFrom[*]}envFrom={.configMapRef.name}{.secretRef.name}{"\n"}{end}{end}' || true
done | tee "$TMP/deploy-env.txt"

echo
echo "[6/12] Busca por OTEL/OpenTelemetry no repositório"
{
  grep -RInE 'OTEL|OpenTelemetry|opentelemetry|trace|tracing|jaeger|tempo|xray|collector' \
    fase2 fase3 fase4 \
    --exclude-dir=.terraform \
    --exclude-dir=.venv \
    --exclude-dir=node_modules \
    --exclude-dir=tmp \
    --exclude='*.log' \
    2>/dev/null || true
} | tee "$TMP/repo-otel-grep.txt"

echo
echo "[7/12] Linguagens e arquivos de dependência dos serviços"
find fase2 fase3 fase4 -maxdepth 6 \( \
  -name 'go.mod' -o \
  -name 'requirements.txt' -o \
  -name 'pyproject.toml' -o \
  -name 'package.json' -o \
  -name 'Dockerfile' \
\) | sort | tee "$TMP/dependency-files.txt"

echo
echo "[8/12] Imagens em execução"
kubectl get pods -n "$APP_NS" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{" "}{end}{"\n"}{end}' | sort | tee "$TMP/app-images.txt"

echo
echo "[9/12] Endpoints e services"
kubectl get svc,endpoints -n "$APP_NS" -o wide | tee "$TMP/app-services.txt"

echo
echo "[10/12] Testes rápidos de conectividade interna existentes"
kubectl get pods -n "$APP_NS" -o wide | tee "$TMP/app-pods.txt"

echo
echo "[11/12] Análise automática inicial"
python3 - <<'PY' > "fase4/tmp/bloco35-0/analysis.txt"
from pathlib import Path
import re

repo_grep = Path("fase4/tmp/bloco35-0/repo-otel-grep.txt").read_text(errors="ignore")
deps = Path("fase4/tmp/bloco35-0/dependency-files.txt").read_text(errors="ignore")
envs = Path("fase4/tmp/bloco35-0/deploy-env.txt").read_text(errors="ignore")
images = Path("fase4/tmp/bloco35-0/app-images.txt").read_text(errors="ignore")

print("## Análise preliminar")
print()

if re.search(r"OTEL|OpenTelemetry|opentelemetry", repo_grep, re.I):
    print("- Foram encontrados sinais de OpenTelemetry/OTEL no repositório. Revisar ocorrências acima.")
else:
    print("- Não foram encontrados sinais fortes de instrumentação OpenTelemetry já existente nos serviços.")

if "go.mod" in deps:
    print("- Há serviços Go no projeto; instrumentação pode exigir bibliotecas/SDK OpenTelemetry para Go ou sidecar/auto-instrumentation se viável.")
if "requirements.txt" in deps or "pyproject.toml" in deps:
    print("- Há serviços Python no projeto; instrumentação pode ser feita por SDK/auto-instrumentation Python se o runtime permitir.")
if "package.json" in deps:
    print("- Há serviços Node.js no projeto; instrumentação pode ser feita por SDK OpenTelemetry JS se aplicável.")

if "OTEL_EXPORTER_OTLP_ENDPOINT" in envs or "OTEL_SERVICE_NAME" in envs:
    print("- Há variáveis OTEL já configuradas em algum Deployment.")
else:
    print("- Não há variáveis OTEL evidentes nos Deployments atuais.")

print()
print("## Próxima decisão sugerida")
print()
print("- Implementar instrumentação mínima e objetiva em um ou mais serviços que participem do fluxo E2E.")
print("- Priorizar o caminho que gere trace real de requisição entre serviços, para preparar Figura 7 e Figura 8.")
print("- Manter OTel Collector como endpoint OTLP interno: http://otel-collector.observability.svc.cluster.local:4318 ou gRPC 4317.")
print()
print("## Imagens futuras")
print()
print("- Figura 7: service map/APM depois que traces reais existirem.")
print("- Figura 8: trace distribuído depois que uma requisição E2E gerar spans encadeados.")
PY

cat "$TMP/analysis.txt"

echo
echo "[12/12] Registrando evidência"
{
  echo
  echo "## Git"
  echo
  echo '```text'
  git log --oneline --decorate -12
  echo '```'
  echo
  echo "## Applications ArgoCD"
  echo
  echo '```text'
  kubectl get application -n "$ARGO_NS" -o wide || true
  echo '```'
  echo
  echo "## Workloads ToggleMaster"
  echo
  echo '```text'
  kubectl get deploy,svc,pods -n "$APP_NS" -o wide || true
  echo '```'
  echo
  echo "## Workloads Observability"
  echo
  echo '```text'
  kubectl get application observability-otel-collector observability-loki observability-promtail observability-kube-prometheus-stack -n "$ARGO_NS" -o wide || true
  kubectl get deploy,svc,pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel-collector|loki|promtail|grafana|prometheus' || true
  echo '```'
  echo
  echo "## Variáveis dos Deployments ToggleMaster"
  echo
  echo '```text'
  cat "$TMP/deploy-env.txt"
  echo '```'
  echo
  echo "## Busca OTEL/OpenTelemetry no repositório"
  echo
  echo '```text'
  cat "$TMP/repo-otel-grep.txt"
  echo '```'
  echo
  echo "## Arquivos de dependência encontrados"
  echo
  echo '```text'
  cat "$TMP/dependency-files.txt"
  echo '```'
  echo
  echo "## Imagens em execução"
  echo
  echo '```text'
  cat "$TMP/app-images.txt"
  echo '```'
  echo
  echo "## Services e endpoints"
  echo
  echo '```text'
  cat "$TMP/app-services.txt"
  echo '```'
  echo
  echo "## Análise preliminar"
  echo
  echo '```text'
  cat "$TMP/analysis.txt"
  echo '```'
} >> "$EVID"

echo
echo "============================================================"
echo "BLOCO 35.0 FINALIZADO"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
