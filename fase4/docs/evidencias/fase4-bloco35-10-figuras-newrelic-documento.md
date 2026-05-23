# Fase 4 - BLOCO 35.10 - Registro das figuras New Relic no documento

Data: Sat May 23 07:51:21 PM -03 2026

## Objetivo
Registrar que as evidências visuais do New Relic foram capturadas e inseridas na seção de APM, tracing distribuído e service map do documento da Fase 4.

## Figuras registradas no documento

### Figura 7
Entidades ToggleMaster detectadas no New Relic após a exportação de traces pelo OpenTelemetry Collector.

Natureza: evidência extra adicionada ao documento para demonstrar que o New Relic reconheceu as entidades APM dos serviços instrumentados.

### Figura 8
Service map do APM no New Relic, demonstrando a comunicação entre o evaluation-service e os serviços flag-service e targeting-service.

Natureza: evidência prevista para comprovar o service map.

### Figura 9
Trace distribuído no New Relic, demonstrando uma requisição real ao endpoint /evaluate propagada entre evaluation-service, flag-service, targeting-service e auth-service.

Natureza: evidência prevista para comprovar distributed tracing.

## Estado das aplicações ArgoCD no momento do registro
```text
NAME                                  SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev                      Synced        Healthy         e6f703f9704e4a4c290d97225d4396a7a42fa663   default
observability-otel-collector          Synced        Healthy         e6f703f9704e4a4c290d97225d4396a7a42fa663   default
observability-kube-prometheus-stack   Synced        Healthy                                                    default
observability-loki                    Synced        Healthy                                                    default
observability-promtail                Synced        Healthy                                                    default
```

## Pods ToggleMaster relevantes
```text
NAME                                  READY   STATUS    RESTARTS        AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-6946467b6b-m7dkk    1/1     Running   0               3h22m   10.10.35.35    ip-10-10-34-177.ec2.internal   <none>           <none>
auth-service-584688f79d-4fvw5         1/1     Running   0               3h16m   10.10.52.161   ip-10-10-51-233.ec2.internal   <none>           <none>
auth-service-584688f79d-lkmfd         1/1     Running   6 (3h16m ago)   3h20m   10.10.47.28    ip-10-10-34-177.ec2.internal   <none>           <none>
evaluation-service-57d59f7b64-sl594   1/1     Running   0               86m     10.10.39.50    ip-10-10-34-177.ec2.internal   <none>           <none>
evaluation-service-57d59f7b64-vfjlq   1/1     Running   0               86m     10.10.49.149   ip-10-10-51-233.ec2.internal   <none>           <none>
flag-service-6d964dcffb-fxtgh         1/1     Running   0               86m     10.10.55.176   ip-10-10-61-91.ec2.internal    <none>           <none>
flag-service-6d964dcffb-rb47f         1/1     Running   0               86m     10.10.36.164   ip-10-10-34-177.ec2.internal   <none>           <none>
targeting-service-599dc5ffd-28pwg     1/1     Running   1 (43m ago)     86m     10.10.34.105   ip-10-10-37-16.ec2.internal    <none>           <none>
targeting-service-599dc5ffd-ftkhh     1/1     Running   0               86m     10.10.60.165   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Pods de observabilidade relevantes
```text
NAME                                                        READY   STATUS    RESTARTS      AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0             3h8m    10.10.62.25    ip-10-10-51-233.ec2.internal   <none>           <none>
kube-prometheus-stack-grafana-84b7d76fd8-t99xl              3/3     Running   0             41m     10.10.59.54    ip-10-10-61-91.ec2.internal    <none>           <none>
kube-prometheus-stack-kube-state-metrics-64659c7c5c-xmbbz   1/1     Running   1 (43m ago)   3h18m   10.10.45.107   ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-operator-8564f47cff-vvvnh             1/1     Running   1 (43m ago)   3h17m   10.10.41.21    ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-2mn94        1/1     Running   1 (43m ago)   3h19m   10.10.37.16    ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-925qv        1/1     Running   0             3h15m   10.10.59.138   ip-10-10-59-138.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-cj27n        1/1     Running   0             3h7m    10.10.61.91    ip-10-10-61-91.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-pgwdt        1/1     Running   0             3h21m   10.10.34.177   ip-10-10-34-177.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-v2m65        1/1     Running   0             3h17m   10.10.51.233   ip-10-10-51-233.ec2.internal   <none>           <none>
loki-0                                                      2/2     Running   0             135m    10.10.53.75    ip-10-10-61-91.ec2.internal    <none>           <none>
otel-collector-79c4cc4ff7-lbxht                             1/1     Running   0             50m     10.10.58.123   ip-10-10-59-138.ec2.internal   <none>           <none>
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   1 (43m ago)   3h8m    10.10.38.89    ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-7czrn                                              1/1     Running   0             171m    10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
promtail-dczbq                                              1/1     Running   0             171m    10.10.51.75    ip-10-10-61-91.ec2.internal    <none>           <none>
promtail-dhlpf                                              1/1     Running   0             171m    10.10.42.215   ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-lx9q4                                              1/1     Running   0             171m    10.10.33.199   ip-10-10-34-177.ec2.internal   <none>           <none>
promtail-twhxw                                              1/1     Running   0             171m    10.10.62.205   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Resultado
As figuras de entidades APM, service map e trace distribuído foram consideradas válidas para compor a seção de APM/tracing do documento da Fase 4.
