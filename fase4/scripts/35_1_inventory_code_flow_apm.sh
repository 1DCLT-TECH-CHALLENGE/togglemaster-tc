#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco35-1-inventario-codigo-fluxo-apm.md"
LOG="$PHASE/docs/evidencias/fase4-bloco35-1-inventario-codigo-fluxo-apm.log"
TMP="$PHASE/tmp/bloco35-1"

APP_NS="togglemaster"
OBS_NS="observability"
ARGO_NS="argocd"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cat > "$EVID" <<'EOM'
# Fase 4 - BLOCO 35.1 - Inventário de código e fluxo E2E para APM/tracing

## Objetivo

Mapear o código, endpoints, dependências, imagens e fluxo E2E antes de implementar instrumentação OpenTelemetry real.

Este bloco não altera recursos Kubernetes, não aplica manifests e não modifica código de aplicação.
EOM

{
  echo
  echo "Data: $(date)"
} >> "$EVID"

echo "[1/13] Estado Git e cluster"
git status --short
git log --oneline --decorate -12
kubectl get application -n "$ARGO_NS" -o wide || true
kubectl get deploy,svc,pods -n "$APP_NS" -o wide || true
kubectl get application observability-otel-collector -n "$ARGO_NS" -o wide || true
kubectl get svc otel-collector -n "$OBS_NS" -o wide || true

echo
echo "[2/13] Estrutura dos serviços fonte"
find fase2/src/services -maxdepth 3 -type f | sort | tee "$TMP/services-files.txt"

echo
echo "[3/13] Arquivos principais por serviço"
for svc in auth-service evaluation-service analytics-service flag-service targeting-service; do
  echo
  echo "==== $svc ===="
  find "fase2/src/services/$svc" -maxdepth 3 -type f 2>/dev/null | sort || true
done | tee "$TMP/service-files-by-service.txt"

echo
echo "[4/13] Endpoints HTTP encontrados no código"
{
  echo "### Go endpoints / handlers"
  grep -RInE 'HandleFunc|http\.Handle|mux\.Handle|router\.|\.GET|\.POST|\.PUT|\.DELETE|ListenAndServe|/health|/evaluate|/flags|/rules|/login|/register' \
    fase2/src/services/auth-service \
    fase2/src/services/evaluation-service \
    2>/dev/null || true

  echo
  echo "### Python Flask/FastAPI endpoints"
  grep -RInE '@app\.route|@.*\.route|Flask|FastAPI|/health|/flags|/rules|/target|/analytics|methods=' \
    fase2/src/services/analytics-service \
    fase2/src/services/flag-service \
    fase2/src/services/targeting-service \
    2>/dev/null || true
} | tee "$TMP/endpoints-code.txt"

echo
echo "[5/13] Chamadas HTTP internas entre serviços"
{
  grep -RInE 'http://|https://|requests\.|http\.Get|http\.Post|NewRequest|SERVICE|_SERVICE|FLAG_SERVICE|TARGETING_SERVICE|AUTH_SERVICE|EVALUATION_SERVICE|ANALYTICS_SERVICE' \
    fase2/src/services \
    fase3/gitops \
    fase4/gitops \
    --exclude-dir=tmp \
    --exclude='*.log' \
    2>/dev/null || true
} | tee "$TMP/internal-calls.txt"

echo
echo "[6/13] Variáveis de ambiente relevantes no código"
{
  grep -RInE 'os\.Getenv|os\.LookupEnv|environ|getenv|DATABASE_URL|SERVICE_API_KEY|MASTER_KEY|REDIS_URL|AWS_SQS_URL|AWS_DYNAMODB_TABLE|FLAG_SERVICE|TARGETING_SERVICE|AUTH_SERVICE|OTEL' \
    fase2/src/services \
    fase3/gitops \
    fase4/gitops \
    --exclude-dir=tmp \
    --exclude='*.log' \
    2>/dev/null || true
} | tee "$TMP/env-vars-code.txt"

echo
echo "[7/13] Dependências atuais"
for file in \
  fase2/src/services/auth-service/go.mod \
  fase2/src/services/evaluation-service/go.mod \
  fase2/src/services/analytics-service/requirements.txt \
  fase2/src/services/flag-service/requirements.txt \
  fase2/src/services/targeting-service/requirements.txt
do
  echo
  echo "==== $file ===="
  if [ -f "$file" ]; then
    cat "$file"
  else
    echo "Arquivo não encontrado"
  fi
done | tee "$TMP/dependencies-current.txt"

echo
echo "[8/13] Dockerfiles e build context"
for file in fase2/src/services/*/Dockerfile; do
  echo
  echo "==== $file ===="
  cat "$file"
done | tee "$TMP/dockerfiles.txt"

echo
echo "[9/13] Manifests GitOps atuais dos serviços"
{
  find fase3/gitops -maxdepth 6 -type f \( -name '*.yaml' -o -name '*.yml' \) | sort
  echo
  echo "---- trechos com image/env/deployment ----"
  grep -RInE 'kind: Deployment|name: .*service|image:|env:|envFrom:|containerPort:|readinessProbe|livenessProbe|SERVICE_API_KEY|DATABASE_URL|OTEL' \
    fase3/gitops \
    fase4/gitops \
    --exclude-dir=tmp \
    2>/dev/null || true
} | tee "$TMP/gitops-current.txt"

echo
echo "[10/13] Imagens em execução e tags atuais"
kubectl get pods -n "$APP_NS" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.name}{"="}{.image}{" "}{end}{"\n"}{end}' | sort | tee "$TMP/runtime-images.txt"

echo
echo "[11/13] Pipelines/workflows de build/deploy"
{
  find .github fase3 fase4 -maxdepth 6 -type f \( -name '*.yml' -o -name '*.yaml' -o -name '*.sh' \) 2>/dev/null | sort
  echo
  echo "---- trechos build/push/ecr/docker ----"
  grep -RInE 'docker build|docker push|ECR|aws ecr|image tag|kubectl set image|kustomize|argocd|buildx|c0f03bb|github.sha' \
    .github fase3 fase4 \
    --exclude-dir=tmp \
    --exclude='*.log' \
    2>/dev/null || true
} | tee "$TMP/build-pipelines.txt"

echo
echo "[12/13] Análise automática e recomendação"
python3 - <<'PY' > "fase4/tmp/bloco35-1/analysis.txt"
from pathlib import Path
import re

endpoints = Path("fase4/tmp/bloco35-1/endpoints-code.txt").read_text(errors="ignore")
calls = Path("fase4/tmp/bloco35-1/internal-calls.txt").read_text(errors="ignore")
deps = Path("fase4/tmp/bloco35-1/dependencies-current.txt").read_text(errors="ignore")
envs = Path("fase4/tmp/bloco35-1/env-vars-code.txt").read_text(errors="ignore")
gitops = Path("fase4/tmp/bloco35-1/gitops-current.txt").read_text(errors="ignore")

services = {
    "auth-service": "Go",
    "evaluation-service": "Go",
    "analytics-service": "Python",
    "flag-service": "Python",
    "targeting-service": "Python",
}

print("## Análise técnica")
print()
print("### Serviços e linguagens")
for svc, lang in services.items():
    print(f"- {svc}: {lang}")

print()
print("### Sinais de instrumentação atual")
if re.search(r'opentelemetry|OTEL_', deps + envs + gitops, re.I):
    print("- Há algum material relacionado a OpenTelemetry/OTEL no repositório/manifests, mas o inventário anterior mostrou que os Deployments dos serviços ainda não têm variáveis OTEL evidentes.")
else:
    print("- Não há instrumentação OpenTelemetry evidente nos serviços atuais.")

print()
print("### Fluxo E2E provável")
flow_hints = []
if "evaluation-service" in calls or "evaluate" in endpoints.lower():
    flow_hints.append("evaluation-service recebe chamadas de avaliação de flag.")
if "flag-service" in calls or "flags" in endpoints.lower():
    flow_hints.append("flag-service participa do cadastro/consulta de flags.")
if "targeting-service" in calls or "rules" in endpoints.lower() or "target" in endpoints.lower():
    flow_hints.append("targeting-service participa das regras de segmentação.")
if flow_hints:
    for item in flow_hints:
        print(f"- {item}")
else:
    print("- Fluxo E2E não ficou totalmente claro apenas por grep; revisar endpoints listados na evidência.")

print()
print("### Estratégia recomendada para instrumentação")
print("- Priorizar o fluxo de avaliação, porque ele é o caminho funcional mais importante para demonstrar APM.")
print("- Começar pelo evaluation-service, pois é Go e é ponto de entrada do fluxo /evaluate.")
print("- Se evaluation-service chamar flag-service/targeting-service via HTTP, propagar tracecontext nos headers para gerar trace distribuído.")
print("- Instrumentar flag-service e/ou targeting-service em Python depois, para fechar spans multi-serviço.")
print("- Configurar OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector.observability.svc.cluster.local:4318 nos Deployments instrumentados.")
print("- Usar nomes de serviço estáveis: togglemaster-evaluation-service, togglemaster-flag-service, togglemaster-targeting-service.")
print()
print("### Decisão operacional sugerida")
print("- Implementar primeiro instrumentação mínima no evaluation-service e um serviço Python chamado por ele, preferencialmente targeting-service ou flag-service.")
print("- Fazer build/push apenas das imagens alteradas.")
print("- Atualizar GitOps com novas tags e variáveis OTEL.")
print("- Validar traces chegando ao OTel Collector.")
print("- Só depois preparar visual de APM/service map/trace distribuído.")
print()
print("### Figuras futuras")
print("- Figura 7: service map/APM depois que o backend de APM estiver recebendo traces reais.")
print("- Figura 8: trace distribuído de uma chamada /evaluate real com spans encadeados.")
PY

cat "$TMP/analysis.txt"

echo
echo "[13/13] Registrando evidência"
{
  echo
  echo "## Estado Git e cluster"
  echo
  echo '```text'
  git log --oneline --decorate -12
  kubectl get application -n "$ARGO_NS" -o wide || true
  kubectl get deploy,svc,pods -n "$APP_NS" -o wide || true
  kubectl get application observability-otel-collector -n "$ARGO_NS" -o wide || true
  kubectl get svc otel-collector -n "$OBS_NS" -o wide || true
  echo '```'
  echo
  echo "## Estrutura dos serviços"
  echo
  echo '```text'
  cat "$TMP/service-files-by-service.txt"
  echo '```'
  echo
  echo "## Endpoints encontrados no código"
  echo
  echo '```text'
  cat "$TMP/endpoints-code.txt"
  echo '```'
  echo
  echo "## Chamadas HTTP internas e referências de services"
  echo
  echo '```text'
  cat "$TMP/internal-calls.txt"
  echo '```'
  echo
  echo "## Variáveis de ambiente relevantes"
  echo
  echo '```text'
  cat "$TMP/env-vars-code.txt"
  echo '```'
  echo
  echo "## Dependências atuais"
  echo
  echo '```text'
  cat "$TMP/dependencies-current.txt"
  echo '```'
  echo
  echo "## Dockerfiles"
  echo
  echo '```text'
  cat "$TMP/dockerfiles.txt"
  echo '```'
  echo
  echo "## GitOps atual"
  echo
  echo '```text'
  cat "$TMP/gitops-current.txt"
  echo '```'
  echo
  echo "## Imagens runtime"
  echo
  echo '```text'
  cat "$TMP/runtime-images.txt"
  echo '```'
  echo
  echo "## Workflows/scripts de build"
  echo
  echo '```text'
  cat "$TMP/build-pipelines.txt"
  echo '```'
  echo
  echo "## Análise e recomendação"
  echo
  echo '```text'
  cat "$TMP/analysis.txt"
  echo '```'
} >> "$EVID"

echo
echo "============================================================"
echo "BLOCO 35.1 FINALIZADO"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
