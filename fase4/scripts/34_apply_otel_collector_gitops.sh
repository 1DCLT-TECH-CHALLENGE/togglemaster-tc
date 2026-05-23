#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
SCRIPT="$PHASE/scripts/34_apply_otel_collector_gitops.sh"
EVID="$PHASE/docs/evidencias/fase4-bloco34-otel-collector.md"
LOG="$PHASE/docs/evidencias/fase4-bloco34-otel-collector.log"
TMP="$PHASE/tmp/bloco34"

APP="observability-otel-collector"
ARGO_NS="argocd"
OBS_NS="observability"
APP_FILE="$PHASE/gitops/apps/observability/otel-collector-application.yaml"
APP_KUSTOMIZATION="$PHASE/gitops/apps/observability/kustomization.yaml"
OTEL_DIR="$PHASE/gitops/observability/otel-collector"

LOCAL_OTLP_PORT="14318"
LOCAL_HEALTH_PORT="11333"

mkdir -p "$PHASE/docs/evidencias" "$TMP" "$OTEL_DIR"

exec > >(tee "$LOG") 2>&1

cleanup() {
  if [ -n "${PF_PID:-}" ]; then
    echo
    echo "Cleanup: encerrando port-forward OTel Collector..."
    kill "$PF_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

cat > "$EVID" <<'EOM'
# Fase 4 - BLOCO 34 - OpenTelemetry Collector via GitOps

## Objetivo

Implantar o OpenTelemetry Collector como hub de telemetria da Fase 4, em modo controlado, via GitOps/ArgoCD.

Este bloco valida:

- manifests GitOps versionados;
- Application ArgoCD;
- pod e service do Collector;
- health endpoint;
- ingestão OTLP/HTTP de telemetria de teste;
- exportação via debug exporter nos logs do Collector.

O APM externo, service map e trace distribuído serão tratados em blocos posteriores.
EOM

{
  echo
  echo "Data: $(date)"
} >> "$EVID"

echo "[1/16] Estado inicial"
git status --short
git log --oneline --decorate -8
kubectl get application -n "$ARGO_NS" || true
kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel|loki|promtail|grafana|prometheus' || true

{
  echo
  echo "## Estado inicial"
  echo
  echo '```text'
  git log --oneline --decorate -8
  kubectl get application -n "$ARGO_NS" || true
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel|loki|promtail|grafana|prometheus' || true
  echo '```'
} >> "$EVID"

echo
echo "[2/16] Criando ConfigMap do OpenTelemetry Collector"
cat > "$OTEL_DIR/configmap.yaml" <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-config
  namespace: observability
  labels:
    app.kubernetes.io/name: otel-collector
    app.kubernetes.io/part-of: togglemaster-observability
data:
  otel-collector-config.yaml: |
    extensions:
      health_check:
        endpoint: 0.0.0.0:13133

    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318

    processors:
      memory_limiter:
        check_interval: 1s
        limit_mib: 128
        spike_limit_mib: 32
      batch: {}

    exporters:
      debug:
        verbosity: detailed
      prometheus:
        endpoint: 0.0.0.0:8889

    service:
      telemetry:
        logs:
          level: info
        metrics:
          address: 0.0.0.0:8888
      extensions:
        - health_check
      pipelines:
        traces:
          receivers:
            - otlp
          processors:
            - memory_limiter
            - batch
          exporters:
            - debug
        metrics:
          receivers:
            - otlp
          processors:
            - memory_limiter
            - batch
          exporters:
            - debug
            - prometheus
        logs:
          receivers:
            - otlp
          processors:
            - memory_limiter
            - batch
          exporters:
            - debug
YAML

echo
echo "[3/16] Criando Deployment"
cat > "$OTEL_DIR/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-collector
  namespace: observability
  labels:
    app.kubernetes.io/name: otel-collector
    app.kubernetes.io/part-of: togglemaster-observability
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: otel-collector
  template:
    metadata:
      labels:
        app.kubernetes.io/name: otel-collector
        app.kubernetes.io/part-of: togglemaster-observability
    spec:
      serviceAccountName: default
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: otel-collector
          image: otel/opentelemetry-collector-contrib:0.111.0
          imagePullPolicy: IfNotPresent
          args:
            - --config=/conf/otel-collector-config.yaml
          ports:
            - name: otlp-grpc
              containerPort: 4317
            - name: otlp-http
              containerPort: 4318
            - name: metrics
              containerPort: 8888
            - name: prometheus
              containerPort: 8889
            - name: health
              containerPort: 13133
          readinessProbe:
            httpGet:
              path: /
              port: health
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 2
            failureThreshold: 6
          livenessProbe:
            httpGet:
              path: /
              port: health
            initialDelaySeconds: 20
            periodSeconds: 20
            timeoutSeconds: 2
            failureThreshold: 6
          resources:
            requests:
              cpu: 50m
              memory: 128Mi
            limits:
              memory: 256Mi
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
          volumeMounts:
            - name: otel-collector-config
              mountPath: /conf
              readOnly: true
      volumes:
        - name: otel-collector-config
          configMap:
            name: otel-collector-config
YAML

echo
echo "[4/16] Criando Service"
cat > "$OTEL_DIR/service.yaml" <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: otel-collector
  namespace: observability
  labels:
    app.kubernetes.io/name: otel-collector
    app.kubernetes.io/part-of: togglemaster-observability
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: otel-collector
  ports:
    - name: otlp-grpc
      port: 4317
      targetPort: otlp-grpc
    - name: otlp-http
      port: 4318
      targetPort: otlp-http
    - name: metrics
      port: 8888
      targetPort: metrics
    - name: prometheus
      port: 8889
      targetPort: prometheus
    - name: health
      port: 13133
      targetPort: health
YAML

echo
echo "[5/16] Criando ServiceMonitor"
cat > "$OTEL_DIR/servicemonitor.yaml" <<'YAML'
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: otel-collector
  namespace: observability
  labels:
    app.kubernetes.io/name: otel-collector
    app.kubernetes.io/part-of: togglemaster-observability
    release: kube-prometheus-stack
spec:
  namespaceSelector:
    matchNames:
      - observability
  selector:
    matchLabels:
      app.kubernetes.io/name: otel-collector
  endpoints:
    - port: metrics
      path: /metrics
      interval: 30s
    - port: prometheus
      path: /metrics
      interval: 30s
YAML

echo
echo "[6/16] Criando kustomization do OTel"
cat > "$OTEL_DIR/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - configmap.yaml
  - deployment.yaml
  - service.yaml
  - servicemonitor.yaml
YAML

echo
echo "[7/16] Criando ArgoCD Application"
cat > "$APP_FILE" <<'YAML'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-otel-collector
  namespace: argocd
  labels:
    app.kubernetes.io/name: otel-collector
    app.kubernetes.io/part-of: togglemaster-observability
spec:
  project: default
  source:
    repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
    targetRevision: main
    path: fase4/gitops/observability/otel-collector
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
YAML

echo
echo "[8/16] Garantindo Application no kustomization de apps"
if [ -f "$APP_KUSTOMIZATION" ]; then
  python3 - <<'PY'
from pathlib import Path

path = Path("fase4/gitops/apps/observability/kustomization.yaml")
text = path.read_text()
resource = "  - otel-collector-application.yaml"

if "otel-collector-application.yaml" not in text:
    if "resources:" not in text:
        text = "apiVersion: kustomize.config.k8s.io/v1beta1\nkind: Kustomization\nresources:\n" + resource + "\n"
    else:
        text = text.rstrip() + "\n" + resource + "\n"
    path.write_text(text)
    print("OK: otel-collector-application.yaml adicionado ao kustomization.")
else:
    print("OK: otel-collector-application.yaml já estava no kustomization.")
PY
else
  cat > "$APP_KUSTOMIZATION" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - otel-collector-application.yaml
YAML
fi

echo
echo "[9/16] Validações locais de render"
kubectl kustomize "$OTEL_DIR" > "$TMP/otel-render.yaml"
kubectl kustomize "$PHASE/gitops/apps/observability" > "$TMP/apps-render.yaml"

grep -n "kind: Deployment" "$TMP/otel-render.yaml"
grep -n "name: otel-collector" "$TMP/otel-render.yaml" | head -20
grep -n "containerPort: 4318" "$TMP/otel-render.yaml"
grep -n "kind: ServiceMonitor" "$TMP/otel-render.yaml"

echo "OK: kustomize render passou."

echo
echo "[10/16] Scanner antes do commit"
python3 - <<'PY'
from pathlib import Path
import re
import sys

files = [
    Path("fase4/gitops/apps/observability/otel-collector-application.yaml"),
    Path("fase4/gitops/apps/observability/kustomization.yaml"),
    Path("fase4/gitops/observability/otel-collector/configmap.yaml"),
    Path("fase4/gitops/observability/otel-collector/deployment.yaml"),
    Path("fase4/gitops/observability/otel-collector/service.yaml"),
    Path("fase4/gitops/observability/otel-collector/servicemonitor.yaml"),
    Path("fase4/gitops/observability/otel-collector/kustomization.yaml"),
    Path("fase4/scripts/34_apply_otel_collector_gitops.sh"),
    Path("fase4/docs/evidencias/fase4-bloco34-otel-collector.md"),
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
echo "[11/16] Registrando patch na evidência"
{
  echo
  echo "## Arquivos GitOps criados"
  echo
  echo '```text'
  find "$OTEL_DIR" -maxdepth 1 -type f | sort
  echo "$APP_FILE"
  echo "$APP_KUSTOMIZATION"
  echo '```'
  echo
  echo "## Validação local"
  echo
  echo '```text'
  echo "kubectl kustomize $OTEL_DIR OK"
  echo "kubectl kustomize $PHASE/gitops/apps/observability OK"
  echo "OTLP HTTP: 4318"
  echo "OTLP gRPC: 4317"
  echo "Health: 13133"
  echo "Metrics: 8888"
  echo "Prometheus exporter: 8889"
  echo '```'
  echo
  echo "## Diff GitOps"
  echo
  echo '```diff'
  git diff -- "$PHASE/gitops/apps/observability" "$OTEL_DIR" "$SCRIPT" "$EVID"
  echo '```'
} >> "$EVID"

echo
echo "[12/16] Commit e push dos manifests"
git status --short

git add "$PHASE/gitops/apps/observability" "$OTEL_DIR" "$SCRIPT" "$EVID"

if git diff --cached --quiet; then
  echo "ERRO: nenhum arquivo staged para commit."
  exit 40
fi

git commit -m "feat: add phase 4 otel collector gitops"
git push origin main

echo
echo "[13/16] Aplicando Application OTel Collector"
kubectl apply -f "$APP_FILE"

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

echo
echo "[14/16] Aguardando OTel Collector Synced/Healthy e Deployment Available"
for attempt in $(seq 1 60); do
  APP_SYNC="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  APP_HEALTH="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  DEP_AVAIL="$(kubectl get deploy otel-collector -n "$OBS_NS" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
  POD_LINE="$(kubectl get pods -n "$OBS_NS" --no-headers 2>/dev/null | awk '/otel-collector/ {print $0}' || true)"

  echo "Tentativa $attempt/60 - app=${APP_SYNC:-N/A}/${APP_HEALTH:-N/A} available=${DEP_AVAIL:-0}"
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel-collector' || true

  if [ "$APP_SYNC" = "Synced" ] && [ "$APP_HEALTH" = "Healthy" ] && [ "${DEP_AVAIL:-0}" -ge 1 ]; then
    echo "OK: OTel Collector Synced/Healthy e Deployment Available."
    break
  fi

  sleep 10
done

APP_SYNC="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
APP_HEALTH="$(kubectl get application "$APP" -n "$ARGO_NS" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
DEP_AVAIL="$(kubectl get deploy otel-collector -n "$OBS_NS" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"

if [ "$APP_SYNC" != "Synced" ] || [ "$APP_HEALTH" != "Healthy" ] || [ "${DEP_AVAIL:-0}" -lt 1 ]; then
  echo "ERRO: OTel Collector não ficou saudável."
  kubectl describe application "$APP" -n "$ARGO_NS" || true
  kubectl describe deploy otel-collector -n "$OBS_NS" || true
  kubectl get events -n "$OBS_NS" --sort-by=.lastTimestamp | tail -80 || true
  exit 50
fi

echo
echo "[15/16] Validando health e envio OTLP/HTTP"
pkill -f "kubectl.*port-forward.*svc/otel-collector" >/dev/null 2>&1 || true
kubectl -n "$OBS_NS" port-forward svc/otel-collector "${LOCAL_OTLP_PORT}:4318" "${LOCAL_HEALTH_PORT}:13133" > "$TMP/otel-port-forward.log" 2>&1 &
PF_PID=$!

sleep 5

if ! kill -0 "$PF_PID" >/dev/null 2>&1; then
  echo "ERRO: port-forward OTel não ficou ativo."
  cat "$TMP/otel-port-forward.log" || true
  exit 60
fi

python3 - <<'PY' > "fase4/tmp/bloco34/otel-health.txt"
import urllib.request
print(urllib.request.urlopen("http://localhost:11333/", timeout=10).read().decode())
PY

cat "$TMP/otel-health.txt"

MARKER="TOGGLEMASTER_OTEL_LOG_$(date +%s)"
echo "MARKER=$MARKER" | tee "$TMP/marker.txt"

python3 - "$MARKER" <<'PY' > "fase4/tmp/bloco34/otel-post-response.txt"
import json
import sys
import time
import urllib.request

marker = sys.argv[1]
now_ns = str(time.time_ns())

payload = {
    "resourceLogs": [
        {
            "resource": {
                "attributes": [
                    {"key": "service.name", "value": {"stringValue": "togglemaster-otel-smoke"}},
                    {"key": "deployment.environment", "value": {"stringValue": "fase4"}},
                    {"key": "namespace", "value": {"stringValue": "togglemaster"}}
                ]
            },
            "scopeLogs": [
                {
                    "scope": {"name": "togglemaster.tc.otel.smoke"},
                    "logRecords": [
                        {
                            "timeUnixNano": now_ns,
                            "severityText": "INFO",
                            "body": {"stringValue": marker},
                            "attributes": [
                                {"key": "tc.marker", "value": {"stringValue": marker}},
                                {"key": "component", "value": {"stringValue": "otel-collector-validation"}}
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}

data = json.dumps(payload).encode()
req = urllib.request.Request(
    "http://localhost:14318/v1/logs",
    data=data,
    headers={"Content-Type": "application/json"},
    method="POST",
)

with urllib.request.urlopen(req, timeout=20) as resp:
    body = resp.read().decode()
    print(f"HTTP_STATUS={resp.status}")
    print(body)
PY

cat "$TMP/otel-post-response.txt"

if ! grep -q "HTTP_STATUS=200" "$TMP/otel-post-response.txt"; then
  echo "ERRO: envio OTLP/HTTP não retornou HTTP 200."
  exit 61
fi

echo
echo "Aguardando debug exporter registrar marker nos logs..."
OTEL_MARKER_FOUND="false"

for attempt in $(seq 1 20); do
  kubectl logs deploy/otel-collector -n "$OBS_NS" --tail=500 > "$TMP/otel-collector-logs.txt" 2>&1 || true

  if grep -q "$MARKER" "$TMP/otel-collector-logs.txt"; then
    OTEL_MARKER_FOUND="true"
    echo "OK: marker encontrado nos logs do OTel Collector na tentativa $attempt."
    break
  fi

  echo "Tentativa $attempt/20 - marker ainda não encontrado."
  sleep 5
done

if [ "$OTEL_MARKER_FOUND" != "true" ]; then
  echo "ERRO: marker OTLP não apareceu nos logs do Collector."
  cat "$TMP/otel-collector-logs.txt" | tail -120 || true
  exit 62
fi

echo
echo "[16/16] Registrando resultado final"
{
  echo
  echo "## Resultado runtime"
  echo
  echo '```text'
  echo "OTEL_APP=$APP_SYNC/$APP_HEALTH"
  echo "DEPLOYMENT_AVAILABLE=$DEP_AVAIL"
  echo "OTLP_HTTP_STATUS=200"
  echo "OTEL_MARKER_FOUND=$OTEL_MARKER_FOUND"
  echo '```'
  echo
  echo "## Application"
  echo
  echo '```text'
  kubectl get application "$APP" -n "$ARGO_NS" -o wide || true
  echo '```'
  echo
  echo "## Pods e Service"
  echo
  echo '```text'
  kubectl get deploy,svc,servicemonitor -n "$OBS_NS" | grep -E 'NAME|otel-collector' || true
  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel-collector' || true
  echo '```'
  echo
  echo "## Health endpoint"
  echo
  echo '```text'
  cat "$TMP/otel-health.txt"
  echo '```'
  echo
  echo "## OTLP HTTP response"
  echo
  echo '```text'
  cat "$TMP/otel-post-response.txt"
  echo '```'
  echo
  echo "## Marker enviado"
  echo
  echo '```text'
  cat "$TMP/marker.txt"
  echo '```'
  echo
  echo "## Evidência no log do Collector"
  echo
  echo '```text'
  grep -A8 -B8 "$MARKER" "$TMP/otel-collector-logs.txt" || true
  echo '```'
} >> "$EVID"

echo
echo "============================================================"
echo "BLOCO 34 FINALIZADO"
echo "OTEL_APP=$APP_SYNC/$APP_HEALTH"
echo "DEPLOYMENT_AVAILABLE=$DEP_AVAIL"
echo "OTEL_MARKER_FOUND=$OTEL_MARKER_FOUND"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
