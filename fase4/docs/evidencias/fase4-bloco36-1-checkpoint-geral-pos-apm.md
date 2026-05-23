# Fase 4 - BLOCO 36.1 - Checkpoint geral pós-APM

Data: Sat May 23 07:53:33 PM -03 2026

## Objetivo
Registrar um checkpoint geral da Fase 4 após a validação de APM, service map e distributed tracing no New Relic.

## Contexto
Até este ponto, a stack de observabilidade da Fase 4 inclui Prometheus/Grafana, Loki/Promtail, OpenTelemetry Collector e New Relic APM. As evidências visuais do New Relic foram inseridas no documento como Figuras 7, 8 e 9.

## Git
```text
9ed27e8 (HEAD -> main, origin/main) docs: record new relic visual evidence
e6f703f docs: record new relic apm traffic
820c6a4 docs: validate new relic ingest key
b622cf4 docs: validate new relic otlp correction
78814f8 fix: correct new relic otlp configuration
7eabb77 docs: validate new relic otel exporter
a0970bf feat: export otel traces to new relic
f887588 docs: validate otel collector traces
e469027 docs: validate otel image rollout
6612b90 feat: rollout otel instrumented service images
b4f0b5c fix: align evaluation image build with go toolchain
ae2d3be feat: instrument evaluation flow with opentelemetry
```

## ArgoCD Applications
```text
NAME                                  SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev                      Synced        Healthy         e6f703f9704e4a4c290d97225d4396a7a42fa663   default
observability-otel-collector          Synced        Healthy         e6f703f9704e4a4c290d97225d4396a7a42fa663   default
observability-kube-prometheus-stack   Synced        Healthy                                                    default
observability-loki                    Synced        Healthy                                                    default
observability-promtail                Synced        Healthy                                                    default
observability-dashboards              Synced        Healthy         e6f703f9704e4a4c290d97225d4396a7a42fa663   default
```

## Pods ToggleMaster
```text
NAME                                  READY   STATUS    RESTARTS        AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-6946467b6b-m7dkk    1/1     Running   0               3h24m   10.10.35.35    ip-10-10-34-177.ec2.internal   <none>           <none>
auth-service-584688f79d-4fvw5         1/1     Running   0               3h18m   10.10.52.161   ip-10-10-51-233.ec2.internal   <none>           <none>
auth-service-584688f79d-lkmfd         1/1     Running   6 (3h18m ago)   3h22m   10.10.47.28    ip-10-10-34-177.ec2.internal   <none>           <none>
evaluation-service-57d59f7b64-sl594   1/1     Running   0               88m     10.10.39.50    ip-10-10-34-177.ec2.internal   <none>           <none>
evaluation-service-57d59f7b64-vfjlq   1/1     Running   0               88m     10.10.49.149   ip-10-10-51-233.ec2.internal   <none>           <none>
flag-service-6d964dcffb-fxtgh         1/1     Running   0               88m     10.10.55.176   ip-10-10-61-91.ec2.internal    <none>           <none>
flag-service-6d964dcffb-rb47f         1/1     Running   0               88m     10.10.36.164   ip-10-10-34-177.ec2.internal   <none>           <none>
targeting-service-599dc5ffd-28pwg     1/1     Running   1 (45m ago)     88m     10.10.34.105   ip-10-10-37-16.ec2.internal    <none>           <none>
targeting-service-599dc5ffd-ftkhh     1/1     Running   0               88m     10.10.60.165   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Pods de observabilidade
```text
NAME                                                        READY   STATUS    RESTARTS      AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0             3h11m   10.10.62.25    ip-10-10-51-233.ec2.internal   <none>           <none>
kube-prometheus-stack-grafana-84b7d76fd8-t99xl              3/3     Running   0             43m     10.10.59.54    ip-10-10-61-91.ec2.internal    <none>           <none>
kube-prometheus-stack-kube-state-metrics-64659c7c5c-xmbbz   1/1     Running   1 (45m ago)   3h20m   10.10.45.107   ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-operator-8564f47cff-vvvnh             1/1     Running   1 (45m ago)   3h19m   10.10.41.21    ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-2mn94        1/1     Running   1 (45m ago)   3h22m   10.10.37.16    ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-925qv        1/1     Running   0             3h18m   10.10.59.138   ip-10-10-59-138.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-cj27n        1/1     Running   0             3h9m    10.10.61.91    ip-10-10-61-91.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-pgwdt        1/1     Running   0             3h23m   10.10.34.177   ip-10-10-34-177.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-v2m65        1/1     Running   0             3h19m   10.10.51.233   ip-10-10-51-233.ec2.internal   <none>           <none>
loki-0                                                      2/2     Running   0             137m    10.10.53.75    ip-10-10-61-91.ec2.internal    <none>           <none>
otel-collector-79c4cc4ff7-lbxht                             1/1     Running   0             52m     10.10.58.123   ip-10-10-59-138.ec2.internal   <none>           <none>
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   1 (45m ago)   3h10m   10.10.38.89    ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-7czrn                                              1/1     Running   0             173m    10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
promtail-dczbq                                              1/1     Running   0             173m    10.10.51.75    ip-10-10-61-91.ec2.internal    <none>           <none>
promtail-dhlpf                                              1/1     Running   0             173m    10.10.42.215   ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-lx9q4                                              1/1     Running   0             173m    10.10.33.199   ip-10-10-34-177.ec2.internal   <none>           <none>
promtail-twhxw                                              1/1     Running   0             173m    10.10.62.205   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Workloads ToggleMaster
```text
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
analytics-service    1/1     1            1           18h
auth-service         2/2     2            2           18h
evaluation-service   2/2     2            2           18h
flag-service         2/2     2            2           18h
targeting-service    2/2     2            2           18h
```

## Workloads observabilidade
```text
NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kube-prometheus-stack-grafana              1/1     1            1           4h18m
deployment.apps/kube-prometheus-stack-kube-state-metrics   1/1     1            1           4h18m
deployment.apps/kube-prometheus-stack-operator             1/1     1            1           4h18m
deployment.apps/otel-collector                             1/1     1            1           155m

NAME                                                               READY   AGE
statefulset.apps/alertmanager-kube-prometheus-stack-alertmanager   1/1     4h18m
statefulset.apps/loki                                              1/1     3h39m
statefulset.apps/prometheus-kube-prometheus-stack-prometheus       1/1     4h18m

NAME                                                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/kube-prometheus-stack-prometheus-node-exporter   5         5         5       5            5           kubernetes.io/os=linux   4h18m
daemonset.apps/promtail                                         5         5         5       5            5           <none>                   173m
```

## OTel Collector / New Relic
```text
PERMISSION_DENIED_COUNT=0
EXPORTER_ERROR_COUNT=0
SERVICE_SPANS_COUNT=540
TRACES_EXPORTER_COUNT=483
```

## Figuras registradas no documento
- Figura 7: entidades ToggleMaster detectadas no New Relic.
- Figura 8: service map do APM no New Relic.
- Figura 9: trace distribuído de uma requisição real ao endpoint /evaluate.

## Resultado do checkpoint
A Fase 4 permanece operacional após a validação visual do New Relic, com as aplicações GitOps sincronizadas, workloads principais em execução e evidências de APM/tracing registradas.
