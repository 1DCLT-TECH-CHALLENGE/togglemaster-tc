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

Data: Sat May 23 05:17:53 PM -03 2026

## Estado inicial

```text
9e4fe3e (HEAD -> main, origin/main) docs: validate promtail logs in loki
539c098 docs: validate loki writable storage fix
2702a34 fix: mount writable var directory for loki
63f1918 docs: validate loki writable storage fix
05a6499 docs: diagnose loki crashloop
65724af docs: diagnose loki sync prune without pyyaml
69e8c64 docs: diagnose loki sync prune
7fad6dc docs: stabilize cluster after lab transition
NAME                                  SYNC STATUS   HEALTH STATUS
observability-dashboards              Synced        Healthy
observability-kube-prometheus-stack   Synced        Healthy
observability-loki                    Synced        Healthy
observability-namespace               Synced        Healthy
observability-promtail                Synced        Healthy
togglemaster-dev                      Synced        Healthy
NAME                                                        READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          35m   10.10.62.25    ip-10-10-51-233.ec2.internal   <none>           <none>
kube-prometheus-stack-grafana-d9b545fd5-7bfct               3/3     Running   0          48s   10.10.60.165   ip-10-10-59-138.ec2.internal   <none>           <none>
kube-prometheus-stack-kube-state-metrics-64659c7c5c-xmbbz   1/1     Running   0          44m   10.10.45.107   ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-operator-8564f47cff-vvvnh             1/1     Running   0          44m   10.10.41.21    ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-2mn94        1/1     Running   0          46m   10.10.37.16    ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-925qv        1/1     Running   0          42m   10.10.59.138   ip-10-10-59-138.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-cj27n        1/1     Running   0          34m   10.10.61.91    ip-10-10-61-91.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-pgwdt        1/1     Running   0          48m   10.10.34.177   ip-10-10-34-177.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-v2m65        1/1     Running   0          44m   10.10.51.233   ip-10-10-51-233.ec2.internal   <none>           <none>
loki-0                                                      2/2     Running   0          23m   10.10.53.75    ip-10-10-61-91.ec2.internal    <none>           <none>
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0          35m   10.10.38.89    ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-7czrn                                              1/1     Running   0          18m   10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
promtail-dczbq                                              1/1     Running   0          18m   10.10.51.75    ip-10-10-61-91.ec2.internal    <none>           <none>
promtail-dhlpf                                              1/1     Running   0          18m   10.10.42.215   ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-lx9q4                                              1/1     Running   0          18m   10.10.33.199   ip-10-10-34-177.ec2.internal   <none>           <none>
promtail-twhxw                                              1/1     Running   0          18m   10.10.62.205   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Arquivos GitOps criados

```text
fase4/gitops/observability/otel-collector/configmap.yaml
fase4/gitops/observability/otel-collector/deployment.yaml
fase4/gitops/observability/otel-collector/kustomization.yaml
fase4/gitops/observability/otel-collector/servicemonitor.yaml
fase4/gitops/observability/otel-collector/service.yaml
fase4/gitops/apps/observability/otel-collector-application.yaml
fase4/gitops/apps/observability/kustomization.yaml
```

## Validação local

```text
kubectl kustomize fase4/gitops/observability/otel-collector OK
kubectl kustomize fase4/gitops/apps/observability OK
OTLP HTTP: 4318
OTLP gRPC: 4317
Health: 13133
Metrics: 8888
Prometheus exporter: 8889
```

## Diff GitOps

```diff
diff --git a/fase4/gitops/apps/observability/kustomization.yaml b/fase4/gitops/apps/observability/kustomization.yaml
index e0521cb..88cae27 100644
--- a/fase4/gitops/apps/observability/kustomization.yaml
+++ b/fase4/gitops/apps/observability/kustomization.yaml
@@ -7,3 +7,4 @@ resources:
   - promtail-application.yaml
   - dashboards-application.yaml
   - opentelemetry-collector-application.yaml
+  - otel-collector-application.yaml
```

## Resultado runtime

```text
OTEL_APP=Synced/Healthy
DEPLOYMENT_AVAILABLE=1
OTLP_HTTP_STATUS=200
OTEL_MARKER_FOUND=true
```

## Application

```text
NAME                           SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-otel-collector   Synced        Healthy         601ec5a1cef9df9dfd95fedc1916a2ce35411dd6   default
```

## Pods e Service

```text
NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/otel-collector                             1/1     1            1           42s
NAME                                                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                         AGE
service/otel-collector                                   ClusterIP   172.20.181.189   <none>        4317/TCP,4318/TCP,8888/TCP,8889/TCP,13133/TCP   42s
NAME                                                                                  AGE
servicemonitor.monitoring.coreos.com/otel-collector                                   42s
NAME                                                        READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
otel-collector-6f554966d7-v7wbh                             1/1     Running   0          43s   10.10.63.217   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Health endpoint

```text
{"status":"Server available","upSince":"2026-05-23T20:18:08.629040878Z","uptime":"32.703748102s"}
```

## OTLP HTTP response

```text
HTTP_STATUS=200
{"partialSuccess":{}}
```

## Marker enviado

```text
MARKER=TOGGLEMASTER_OTEL_LOG_1779567521
```

## Evidência no log do Collector

```text
ScopeLogs #0
ScopeLogs SchemaURL: 
InstrumentationScope togglemaster.tc.otel.smoke 
LogRecord #0
ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2026-05-23 20:18:41.523517314 +0000 UTC
SeverityText: INFO
SeverityNumber: Unspecified(0)
Body: Str(TOGGLEMASTER_OTEL_LOG_1779567521)
Attributes:
     -> tc.marker: Str(TOGGLEMASTER_OTEL_LOG_1779567521)
     -> component: Str(otel-collector-validation)
Trace ID: 
Span ID: 
Flags: 0
	{"kind": "exporter", "data_type": "logs", "name": "debug"}
```
