# Fase 4 - Recovery pós-paste acidental - checkpoint final

Data: Sat May 23 08:17:14 PM -03 2026

## Contexto
Durante a retomada pós-APM, houve paste acidental de logs no terminal, fazendo o shell interpretar trechos de saída como comandos.

## Recuperação executada
- O working tree foi limpo.
- Os commits acidentais de Loki foram revertidos sem force push.
- O diff lógico contra o checkpoint bom 263cf6b ficou vazio.
- O kube-prometheus-stack foi ressincronizado via ArgoCD.

## Estado Git
```text
6266606 (HEAD -> main, origin/main) Revert "fix: mount writable var directory for loki"
e41c708 Revert "fix: disable loki caches for phase 4 lab"
4d2ad3d (backup/recovery-before-revert-20260523-201159) fix: disable loki caches for phase 4 lab
4207f68 fix: mount writable var directory for loki
263cf6b docs: audit phase 4 deliverables
4254d97 docs: record phase 4 post apm checkpoint
9ed27e8 docs: record new relic visual evidence
e6f703f docs: record new relic apm traffic
820c6a4 docs: validate new relic ingest key
b622cf4 docs: validate new relic otlp correction
78814f8 fix: correct new relic otlp configuration
7eabb77 docs: validate new relic otel exporter
```

## Estado ArgoCD
```text
NAME                                  SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev                      Synced        Healthy         62666064df26c8aa078e61285412865cd0b2c46f   default
observability-kube-prometheus-stack   Synced        Healthy                                                    default
observability-loki                    Synced        Healthy                                                    default
observability-promtail                Synced        Healthy                                                    default
observability-otel-collector          Synced        Healthy         4d2ad3d903bf4df38e57fdc994e1efa2b6da0c53   default
observability-dashboards              Synced        Healthy         4d2ad3d903bf4df38e57fdc994e1efa2b6da0c53   default
```

## Pods de observabilidade
```text
NAME                                                        READY   STATUS    RESTARTS        AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0               3h34m   10.10.62.25    ip-10-10-51-233.ec2.internal   <none>           <none>
kube-prometheus-stack-grafana-58c9f75dfb-hjpqm              3/3     Running   0               2m27s   10.10.38.89    ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-kube-state-metrics-64659c7c5c-7jdg9   1/1     Running   0               11m     10.10.54.213   ip-10-10-61-91.ec2.internal    <none>           <none>
kube-prometheus-stack-operator-8564f47cff-f776w             1/1     Running   0               11m     10.10.59.54    ip-10-10-61-91.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-2mn94        1/1     Running   2 (5m39s ago)   3h45m   10.10.37.16    ip-10-10-37-16.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-925qv        1/1     Running   0               3h41m   10.10.59.138   ip-10-10-59-138.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-cj27n        1/1     Running   0               3h33m   10.10.61.91    ip-10-10-61-91.ec2.internal    <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-pgwdt        1/1     Running   0               3h47m   10.10.34.177   ip-10-10-34-177.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-v2m65        1/1     Running   0               3h43m   10.10.51.233   ip-10-10-51-233.ec2.internal   <none>           <none>
loki-0                                                      2/2     Running   0               16m     10.10.63.217   ip-10-10-59-138.ec2.internal   <none>           <none>
otel-collector-79c4cc4ff7-lbxht                             1/1     Running   0               76m     10.10.58.123   ip-10-10-59-138.ec2.internal   <none>           <none>
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0               5m35s   10.10.45.107   ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-7czrn                                              1/1     Running   0               3h17m   10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
promtail-dczbq                                              1/1     Running   0               3h17m   10.10.51.75    ip-10-10-61-91.ec2.internal    <none>           <none>
promtail-dhlpf                                              1/1     Running   0               3h17m   10.10.42.215   ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-lx9q4                                              1/1     Running   0               3h17m   10.10.33.199   ip-10-10-34-177.ec2.internal   <none>           <none>
promtail-twhxw                                              1/1     Running   0               3h17m   10.10.62.205   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Resultado
Ambiente recuperado e estabilizado antes do fim da sessão AWS Academy. Próximo passo técnico: retomar a implementação do alerta Prometheus em estado Firing.
