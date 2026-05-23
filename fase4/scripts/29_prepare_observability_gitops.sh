#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco29-gitops-helm-observability.md"
ADR="$PHASE/docs/adr/ADR-004-fase4-gitops-helm-observability-stack.md"
LOG="$PHASE/docs/evidencias/fase4-bloco29-gitops-helm-observability.log"
TMP="$PHASE/tmp/bloco29"

APP_NS="togglemaster"
OBS_NS="observability"
ARGO_NS="argocd"

mkdir -p "$PHASE/docs/evidencias" "$PHASE/docs/adr" "$TMP"

exec > >(tee "$LOG") 2>&1

section() {
  echo
  echo "============================================================"
  echo "$1"
  echo "============================================================"
  echo
  {
    echo
    echo "## $1"
    echo
  } >> "$EVID"
}

record_cmd() {
  local title="$1"
  shift

  echo
  echo "### $title"
  echo "\$ $*"
  echo

  {
    echo
    echo "### $title"
    echo
    echo '```bash'
    echo "\$ $*"
  } >> "$EVID"

  set +e
  "$@" 2>&1 | tee "$TMP/last.out"
  local rc=${PIPESTATUS[0]}
  set -e

  cat "$TMP/last.out" >> "$EVID"

  {
    echo
    echo '```'
    echo
    echo "RC: \`$rc\`"
  } >> "$EVID"

  echo
  echo "RC=$rc"
  return "$rc"
}

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 29 - Preparação GitOps/Helm da Observabilidade

Data: $(date)

## Objetivo

Preparar os manifests GitOps e os Helm values da stack base de observabilidade da Fase 4.

Este bloco:

- cria manifests GitOps;
- cria valores Helm versionados;
- cria dashboard customizado inicial do Grafana;
- valida render com \`kustomize build\` e \`helm template\`;
- não executa \`kubectl apply\`;
- não executa \`argocd sync\`;
- não instala nada no cluster.

EOM

echo "============================================================"
echo "FASE 4 - BLOCO 29 - GITOPS/HELM OBSERVABILITY"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado Git inicial"

record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -10

allowed_bloco29_status_filter() {
  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability\.md$|^\?\? fase4/docs/adr/ADR-004-fase4-gitops-helm-observability-stack\.md$|^\?\? fase4/scripts/29_prepare_observability_gitops\.sh$|^\?\? fase4/scripts/$' || true
}

UNEXPECTED_STATUS="$(git status --short | allowed_bloco29_status_filter)"
if [ -n "$UNEXPECTED_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do BLOCO 29:"
  echo "$UNEXPECTED_STATUS"
  echo "- ERRO: Git tem alterações inesperadas no início do BLOCO 29." >> "$EVID"
  exit 10
fi

echo "OK: Git limpo, exceto artefatos esperados do próprio BLOCO 29."
echo "- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 29." >> "$EVID"

section "2. Pré-checks do cluster e capacidade"

record_cmd "kubectl context" kubectl config current-context
record_cmd "ArgoCD app ToggleMaster" kubectl get application togglemaster-dev -n "$ARGO_NS" -o wide
record_cmd "Nodes atuais" kubectl get nodes -o wide
record_cmd "Pods atuais" kubectl get pods -A -o wide

ARGO_STATUS="$(kubectl get application togglemaster-dev -n "$ARGO_NS" -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
READY_NODES="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 == "Ready" {count++} END {print count+0}')"
TOTAL_NODES="$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"

echo "ARGO_STATUS=$ARGO_STATUS"
echo "TOTAL_NODES=$TOTAL_NODES"
echo "READY_NODES=$READY_NODES"

if [ "$ARGO_STATUS" != "Synced/Healthy" ]; then
  echo "ERRO: ArgoCD togglemaster-dev não está Synced/Healthy."
  exit 20
fi

if [ "$TOTAL_NODES" -lt 5 ] || [ "$READY_NODES" -lt 5 ]; then
  echo "ERRO: capacidade esperada pós-BLOCO 28 não encontrada."
  exit 21
fi

section "3. Preparar Helm repositories e descobrir versões"

record_cmd "Helm version" helm version

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts >/dev/null 2>&1 || true

record_cmd "Helm repo update" helm repo update

chart_version() {
  local chart="$1"
  local outfile="$TMP/$(echo "$chart" | tr '/:' '__').json"

  helm search repo "$chart" -o json > "$outfile"

  python3 - "$outfile" "$chart" <<'CHARTPY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
chart = sys.argv[2]

text = path.read_text(errors="ignore").strip()
if not text:
    raise SystemExit(f"{chart}: helm search retornou JSON vazio")

data = json.loads(text)
if not data:
    raise SystemExit(f"{chart}: chart não encontrado no helm search")

version = data[0].get("version")
if not version:
    raise SystemExit(f"{chart}: campo version ausente no resultado")

print(version)
CHARTPY
}

PROM_STACK_VERSION="$(chart_version prometheus-community/kube-prometheus-stack)"
LOKI_VERSION="$(chart_version grafana/loki)"
PROMTAIL_VERSION="$(chart_version grafana/promtail)"
OTEL_COLLECTOR_VERSION="$(chart_version open-telemetry/opentelemetry-collector)"

echo "PROM_STACK_VERSION=$PROM_STACK_VERSION"
echo "LOKI_VERSION=$LOKI_VERSION"
echo "PROMTAIL_VERSION=$PROMTAIL_VERSION"
echo "OTEL_COLLECTOR_VERSION=$OTEL_COLLECTOR_VERSION"

{
  echo
  echo "### Versões Helm selecionadas"
  echo
  echo "- kube-prometheus-stack: \`$PROM_STACK_VERSION\`"
  echo "- loki: \`$LOKI_VERSION\`"
  echo "- promtail: \`$PROMTAIL_VERSION\`"
  echo "- opentelemetry-collector: \`$OTEL_COLLECTOR_VERSION\`"
} >> "$EVID"

section "4. Criar estrutura GitOps da Fase 4"

mkdir -p \
  fase4/gitops/apps/observability \
  fase4/gitops/observability/namespace \
  fase4/gitops/observability/values \
  fase4/gitops/observability/dashboards \
  fase4/dashboards/grafana

REPO_URL="$(kubectl get application togglemaster-dev -n "$ARGO_NS" -o jsonpath='{.spec.source.repoURL}' 2>/dev/null || true)"
TARGET_REVISION="$(kubectl get application togglemaster-dev -n "$ARGO_NS" -o jsonpath='{.spec.source.targetRevision}' 2>/dev/null || true)"

if [ -z "$REPO_URL" ]; then
  REPO_URL="git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git"
fi

if [ -z "$TARGET_REVISION" ]; then
  TARGET_REVISION="main"
fi

echo "REPO_URL=$REPO_URL"
echo "TARGET_REVISION=$TARGET_REVISION"

cat > fase4/gitops/observability/namespace/namespace.yaml <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: observability
  labels:
    app.kubernetes.io/name: observability
    app.kubernetes.io/part-of: togglemaster
    togglemaster.io/phase: "4"
EOF

cat > fase4/gitops/observability/namespace/kustomization.yaml <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
EOF

cat > fase4/gitops/observability/values/kube-prometheus-stack-values.yaml <<'EOF'
fullnameOverride: kube-prometheus-stack

crds:
  enabled: true

alertmanager:
  enabled: true
  alertmanagerSpec:
    replicas: 1
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        memory: 256Mi

grafana:
  enabled: true
  replicas: 1
  defaultDashboardsEnabled: true
  admin:
    existingSecret: ""
  service:
    type: ClusterIP
  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      searchNamespace: observability
  additionalDataSources:
    - name: Loki
      type: loki
      access: proxy
      url: http://loki.observability.svc.cluster.local:3100
      isDefault: false
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      memory: 512Mi

prometheusOperator:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      memory: 512Mi

prometheus:
  prometheusSpec:
    replicas: 1
    retention: 6h
    scrapeInterval: 30s
    evaluationInterval: 30s
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    resources:
      requests:
        cpu: 150m
        memory: 384Mi
      limits:
        memory: 1Gi

kubeStateMetrics:
  enabled: true

nodeExporter:
  enabled: true

defaultRules:
  create: true
  rules:
    etcd: false
    kubeScheduler: false
    kubeControllerManager: false
EOF

cat > fase4/gitops/observability/values/loki-values.yaml <<'EOF'
deploymentMode: SingleBinary

loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: filesystem
  schemaConfig:
    configs:
      - from: "2024-01-01"
        store: tsdb
        object_store: filesystem
        schema: v13
        index:
          prefix: index_
          period: 24h
  limits_config:
    retention_period: 24h
  compactor:
    retention_enabled: true
    delete_request_store: filesystem

singleBinary:
  replicas: 1
  persistence:
    enabled: false
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      memory: 768Mi

gateway:
  enabled: false

lokiCanary:
  enabled: false

test:
  enabled: false

monitoring:
  selfMonitoring:
    enabled: false
  lokiCanary:
    enabled: false

backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0
EOF

cat > fase4/gitops/observability/values/promtail-values.yaml <<'EOF'
config:
  clients:
    - url: http://loki.observability.svc.cluster.local:3100/loki/api/v1/push
  snippets:
    extraRelabelConfigs:
      - source_labels:
          - __meta_kubernetes_namespace
        target_label: namespace
      - source_labels:
          - __meta_kubernetes_pod_name
        target_label: pod
      - source_labels:
          - __meta_kubernetes_pod_container_name
        target_label: container

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    memory: 256Mi

tolerations:
  - operator: Exists
EOF

cat > fase4/gitops/observability/values/opentelemetry-collector-values.yaml <<'EOF'
mode: deployment

image:
  repository: otel/opentelemetry-collector-contrib

replicaCount: 1

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    memory: 512Mi

ports:
  otlp:
    enabled: true
    containerPort: 4317
    servicePort: 4317
    protocol: TCP
  otlp-http:
    enabled: true
    containerPort: 4318
    servicePort: 4318
    protocol: TCP
  metrics:
    enabled: true
    containerPort: 8889
    servicePort: 8889
    protocol: TCP

service:
  enabled: true

serviceMonitor:
  enabled: true
  metricsEndpoints:
    - port: metrics

config:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318

  processors:
    batch: {}

  exporters:
    debug: {}
    prometheus:
      endpoint: 0.0.0.0:8889

  service:
    pipelines:
      traces:
        receivers: [otlp]
        processors: [batch]
        exporters: [debug]
      metrics:
        receivers: [otlp]
        processors: [batch]
        exporters: [prometheus, debug]
      logs:
        receivers: [otlp]
        processors: [batch]
        exporters: [debug]
EOF

cat > fase4/dashboards/grafana/togglemaster-ecosystem-dashboard.json <<'EOF'
{
  "uid": "togglemaster-ecosystem",
  "title": "ToggleMaster - Observability Overview",
  "tags": ["togglemaster", "phase4", "observability"],
  "timezone": "browser",
  "schemaVersion": 39,
  "version": 1,
  "refresh": "30s",
  "panels": [
    {
      "type": "stat",
      "title": "Running Pods - ToggleMaster",
      "gridPos": {"x": 0, "y": 0, "w": 6, "h": 4},
      "targets": [
        {
          "expr": "sum(kube_pod_status_phase{namespace=\"togglemaster\",phase=\"Running\"})",
          "legendFormat": "running pods",
          "refId": "A"
        }
      ]
    },
    {
      "type": "stat",
      "title": "Ready Nodes",
      "gridPos": {"x": 6, "y": 0, "w": 6, "h": 4},
      "targets": [
        {
          "expr": "sum(kube_node_status_condition{condition=\"Ready\",status=\"true\"})",
          "legendFormat": "ready nodes",
          "refId": "A"
        }
      ]
    },
    {
      "type": "timeseries",
      "title": "CPU Usage by ToggleMaster Pod",
      "gridPos": {"x": 0, "y": 4, "w": 12, "h": 8},
      "targets": [
        {
          "expr": "sum(rate(container_cpu_usage_seconds_total{namespace=\"togglemaster\",container!=\"\"}[5m])) by (pod)",
          "legendFormat": "{{pod}}",
          "refId": "A"
        }
      ]
    },
    {
      "type": "timeseries",
      "title": "Memory Usage by ToggleMaster Pod",
      "gridPos": {"x": 12, "y": 4, "w": 12, "h": 8},
      "targets": [
        {
          "expr": "sum(container_memory_working_set_bytes{namespace=\"togglemaster\",container!=\"\"}) by (pod)",
          "legendFormat": "{{pod}}",
          "refId": "A"
        }
      ]
    },
    {
      "type": "logs",
      "title": "ToggleMaster Logs - Loki",
      "gridPos": {"x": 0, "y": 12, "w": 24, "h": 8},
      "targets": [
        {
          "expr": "{namespace=\"togglemaster\"}",
          "refId": "A"
        }
      ]
    }
  ]
}
EOF

python3 - <<'DASHBOARDPY'
from pathlib import Path

dashboard = Path("fase4/dashboards/grafana/togglemaster-ecosystem-dashboard.json").read_text()
indented_dashboard = "\n".join("    " + line for line in dashboard.splitlines())

yaml_text = f"""apiVersion: v1
kind: ConfigMap
metadata:
  name: togglemaster-grafana-dashboard
  namespace: observability
  labels:
    grafana_dashboard: "1"
    app.kubernetes.io/name: togglemaster-grafana-dashboard
    app.kubernetes.io/part-of: togglemaster
    togglemaster.io/phase: "4"
data:
  togglemaster-ecosystem-dashboard.json: |
{indented_dashboard}
"""

Path("fase4/gitops/observability/dashboards/togglemaster-grafana-dashboard.yaml").write_text(yaml_text)
DASHBOARDPY

cat > fase4/gitops/observability/dashboards/kustomization.yaml <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - togglemaster-grafana-dashboard.yaml
EOF

cat > fase4/gitops/apps/observability/namespace-application.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-namespace
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${TARGET_REVISION}
    path: fase4/gitops/observability/namespace
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

cat > fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-kube-prometheus-stack
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "10"
spec:
  project: default
  sources:
    - repoURL: https://prometheus-community.github.io/helm-charts
      chart: kube-prometheus-stack
      targetRevision: ${PROM_STACK_VERSION}
      helm:
        releaseName: kube-prometheus-stack
        valueFiles:
          - \$values/fase4/gitops/observability/values/kube-prometheus-stack-values.yaml
    - repoURL: ${REPO_URL}
      targetRevision: ${TARGET_REVISION}
      ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
EOF

cat > fase4/gitops/apps/observability/loki-application.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-loki
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "20"
spec:
  project: default
  sources:
    - repoURL: https://grafana.github.io/helm-charts
      chart: loki
      targetRevision: ${LOKI_VERSION}
      helm:
        releaseName: loki
        valueFiles:
          - \$values/fase4/gitops/observability/values/loki-values.yaml
    - repoURL: ${REPO_URL}
      targetRevision: ${TARGET_REVISION}
      ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
EOF

cat > fase4/gitops/apps/observability/promtail-application.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-promtail
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "21"
spec:
  project: default
  sources:
    - repoURL: https://grafana.github.io/helm-charts
      chart: promtail
      targetRevision: ${PROMTAIL_VERSION}
      helm:
        releaseName: promtail
        valueFiles:
          - \$values/fase4/gitops/observability/values/promtail-values.yaml
    - repoURL: ${REPO_URL}
      targetRevision: ${TARGET_REVISION}
      ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
EOF

cat > fase4/gitops/apps/observability/dashboards-application.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-dashboards
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "30"
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${TARGET_REVISION}
    path: fase4/gitops/observability/dashboards
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

cat > fase4/gitops/apps/observability/opentelemetry-collector-application.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-opentelemetry-collector
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "30"
spec:
  project: default
  sources:
    - repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts
      chart: opentelemetry-collector
      targetRevision: ${OTEL_COLLECTOR_VERSION}
      helm:
        releaseName: opentelemetry-collector
        valueFiles:
          - \$values/fase4/gitops/observability/values/opentelemetry-collector-values.yaml
    - repoURL: ${REPO_URL}
      targetRevision: ${TARGET_REVISION}
      ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
EOF

cat > fase4/gitops/apps/observability/kustomization.yaml <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace-application.yaml
  - kube-prometheus-stack-application.yaml
  - loki-application.yaml
  - promtail-application.yaml
  - dashboards-application.yaml
  - opentelemetry-collector-application.yaml
EOF

cat > "$ADR" <<EOF
# ADR-004 - GitOps e Helm para Stack Base de Observabilidade

## Status

Proposta preparada para aplicação em bloco posterior.

## Contexto

A Fase 4 exige uma stack open source com Prometheus, Grafana e Loki no Kubernetes, além do OpenTelemetry Collector como componente obrigatório.

Após o BLOCO 28, o cluster possui capacidade suficiente para iniciar a instalação controlada.

## Decisão

Preparar a stack usando GitOps/ArgoCD e Helm charts versionados:

- \`kube-prometheus-stack\` para Prometheus, Grafana, Alertmanager, kube-state-metrics e node-exporter;
- \`loki\` para centralização de logs;
- \`promtail\` para coleta de logs dos pods;
- \`opentelemetry-collector\` para receber telemetria OTLP e expor métricas;
- dashboard customizado inicial do ToggleMaster carregado via ConfigMap.

## Versões selecionadas no BLOCO 29

- kube-prometheus-stack: \`${PROM_STACK_VERSION}\`
- loki: \`${LOKI_VERSION}\`
- promtail: \`${PROMTAIL_VERSION}\`
- opentelemetry-collector: \`${OTEL_COLLECTOR_VERSION}\`

## Consequências

- Este bloco não instala nada.
- O próximo bloco deve aplicar os ArgoCD Applications em ordem controlada.
- Após a instalação, será necessário validar pods, services, targets, Grafana, Loki e OTel.
- A instrumentação dos microsserviços será tratada em blocos posteriores.
EOF

section "5. Validar render local"

record_cmd "Kustomize namespace observability" kubectl kustomize fase4/gitops/observability/namespace
record_cmd "Kustomize dashboards observability" kubectl kustomize fase4/gitops/observability/dashboards
record_cmd "Kustomize ArgoCD applications observability" kubectl kustomize fase4/gitops/apps/observability

record_cmd "Helm template kube-prometheus-stack" helm template kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version "$PROM_STACK_VERSION" \
  --namespace observability \
  -f fase4/gitops/observability/values/kube-prometheus-stack-values.yaml

record_cmd "Helm template loki" helm template loki grafana/loki \
  --version "$LOKI_VERSION" \
  --namespace observability \
  -f fase4/gitops/observability/values/loki-values.yaml

record_cmd "Helm template promtail" helm template promtail grafana/promtail \
  --version "$PROMTAIL_VERSION" \
  --namespace observability \
  -f fase4/gitops/observability/values/promtail-values.yaml

record_cmd "Helm template opentelemetry-collector" helm template opentelemetry-collector open-telemetry/opentelemetry-collector \
  --version "$OTEL_COLLECTOR_VERSION" \
  --namespace observability \
  -f fase4/gitops/observability/values/opentelemetry-collector-values.yaml

section "6. Conferência dos artefatos criados"

record_cmd "Arquivos GitOps Fase 4" find fase4/gitops -maxdepth 6 -type f | sort
record_cmd "Dashboard Grafana" ls -la fase4/dashboards/grafana/togglemaster-ecosystem-dashboard.json
record_cmd "Diff stat" git diff --stat

cat >> "$EVID" <<EOF

## Artefatos preparados

- Namespace GitOps: \`fase4/gitops/observability/namespace\`
- Applications ArgoCD: \`fase4/gitops/apps/observability\`
- Helm values: \`fase4/gitops/observability/values\`
- Dashboard customizado: \`fase4/dashboards/grafana/togglemaster-ecosystem-dashboard.json\`
- Dashboard ConfigMap: \`fase4/gitops/observability/dashboards/togglemaster-grafana-dashboard.yaml\`
- ADR: \`$ADR\`

## Observação

Nenhum componente foi instalado no cluster neste bloco.

EOF

section "7. Segurança"

record_cmd "Check state/tfvars/bin versionados" bash -lc "git ls-files | grep -E '(^|/).*\\.tfstate(\\.backup)?$|(^|/)terraform\\.tfvars$|\\.auto\\.tfvars$|(^|/).*tfplan.*|(^|/).*\\.bin$' || true"

TRACKED_SENSITIVE_FILES="$(git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$|(^|/).*tfplan.*|(^|/).*\.bin$' || true)"
if [ -n "$TRACKED_SENSITIVE_FILES" ]; then
  echo "ERRO: state/tfvars/plan binário versionado detectado."
  echo "$TRACKED_SENSITIVE_FILES"
  exit 70
fi

section "8. Resultado"

cat >> "$EVID" <<EOF

## Resultado

BLOCO 29 concluído com sucesso.

- GitOps/Helm preparado.
- Render local validado.
- Nenhum \`kubectl apply\` executado.
- Nenhum \`argocd sync\` executado.
- Nenhuma stack instalada ainda.

Próximo bloco recomendado:

1. aplicar os ArgoCD Applications da observabilidade;
2. aguardar sync/health;
3. validar pods/services;
4. iniciar validação do Grafana, Loki e OTel.

EOF

echo
echo "============================================================"
echo "BLOCO 29 FINALIZADO"
echo "GitOps/Helm preparado e render validado."
echo "Evidência: $EVID"
echo "ADR: $ADR"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
