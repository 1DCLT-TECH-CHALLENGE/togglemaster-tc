# Fase 4 - BLOCO 36.2 - Auditoria dos entregáveis oficiais

Data: Sat May 23 07:56:49 PM -03 2026

## Objetivo
Auditar a estrutura do repositório, evidências existentes e estado read-only do cluster contra os requisitos oficiais/operacionais da Fase 4.

## Resultado resumido
A auditoria confirma que Prometheus/Grafana, Loki/Promtail, OpenTelemetry Collector e New Relic/APM estão implementados e evidenciados. Os próximos itens críticos são alertas inteligentes, incidente automático, ChatOps, self-healing, prova real de incidente, fechamento do relatório e preparação do vídeo.

## Matriz auditada

| ID | Requisito | Status auditado | Evidência/observação |
|---|---|---|---|
| F4-01 | Prometheus | OK | kube-prometheus-stack Synced/Healthy e pods Prometheus/exporters Running |
| F4-02 | Loki | OK | Loki Synced/Healthy e pod loki Running |
| F4-03 | Grafana dashboard | OK | Grafana Running e evidências de dashboard existentes |
| F4-04 | OpenTelemetry Collector | OK | OTel Collector Synced/Healthy e Running |
| F4-05 | Instrumentação dos serviços | OK PARCIAL | Fluxo principal instrumentado e validado; confirmar no texto que auth/analytics entram como dependências/pipeline |
| F4-06 | APM New Relic / Service Map / Trace | OK | Service Map e trace distribuído validados e registrados |
| F4-07 | Alertas inteligentes | PENDENTE | Ainda falta demonstrar alerta em estado Firing |
| F4-08 | Incident Management | PENDENTE | Ainda falta incidente automático em PagerDuty/OpsGenie |
| F4-09 | ChatOps | PENDENTE | Ainda falta notificação ChatOps |
| F4-10 | Self-Healing | EM ANDAMENTO | Há arquivos relacionados; ainda precisa demonstrar execução corretiva real |
| F4-11 | Prova real de incidente | PENDENTE | Ainda falta cadeia completa de incidente |
| F4-12 | Relatório final PDF | PENDENTE | Ainda falta relatório final |
| F4-13 | Vídeo até 25 min | PENDENTE | Ainda falta roteiro/link do vídeo |

## Pastas esperadas da Fase 4
```text
OK  fase4
OK  fase4/docs
OK  fase4/docs/evidencias
OK  fase4/docs/adr
OK  fase4/gitops
OK  fase4/gitops/observability
OK  fase4/dashboards
OK  fase4/dashboards/grafana
OK  fase4/alerting
OK  fase4/self-healing
OK  fase4/scripts
OK  fase4/relatorio
OK  fase4/video
```

## Git
```text
4254d97 (HEAD -> main, origin/main) docs: record phase 4 post apm checkpoint
9ed27e8 docs: record new relic visual evidence
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
b467907 docs: snapshot tracing instrumentation targets
607bd91 docs: plan phase 4 apm instrumentation
```

## ArgoCD Applications
```text
NAME                                  SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-dashboards              Synced        Healthy         4254d97b83fb86fbbb40ad1e593d7d3dd38ef3fe   default
observability-kube-prometheus-stack   Synced        Healthy                                                    default
observability-loki                    Synced        Healthy                                                    default
observability-namespace               Synced        Healthy         e6f703f9704e4a4c290d97225d4396a7a42fa663   default
observability-otel-collector          Synced        Healthy         e6f703f9704e4a4c290d97225d4396a7a42fa663   default
observability-promtail                Synced        Healthy                                                    default
togglemaster-dev                      Synced        Healthy         e6f703f9704e4a4c290d97225d4396a7a42fa663   default
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

## Workloads observability
```text
NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kube-prometheus-stack-grafana              1/1     1            1           4h22m
deployment.apps/kube-prometheus-stack-kube-state-metrics   1/1     1            1           4h22m
deployment.apps/kube-prometheus-stack-operator             1/1     1            1           4h22m
deployment.apps/otel-collector                             1/1     1            1           158m

NAME                                                               READY   AGE
statefulset.apps/alertmanager-kube-prometheus-stack-alertmanager   1/1     4h22m
statefulset.apps/loki                                              1/1     3h42m
statefulset.apps/prometheus-kube-prometheus-stack-prometheus       1/1     4h22m

NAME                                                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/kube-prometheus-stack-prometheus-node-exporter   5         5         5       5            5           kubernetes.io/os=linux   4h22m
daemonset.apps/promtail                                         5         5         5       5            5           <none>                   176m
```

## Evidências Fase 4 encontradas
```text
fase4/docs/evidencias/fase4-bloco22-abertura.md
fase4/docs/evidencias/fase4-bloco23-inventario-stack.log
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.log
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md
fase4/docs/evidencias/fase4-bloco26-iac-capacidade-eks.log
fase4/docs/evidencias/fase4-bloco26-iac-capacidade-eks.md
fase4/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks.log
fase4/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks.md
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.log
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.log
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.log
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md
fase4/docs/evidencias/fase4-bloco31-grafana-access.log
fase4/docs/evidencias/fase4-bloco31-grafana-access.md
fase4/docs/evidencias/fase4-bloco32-grafana-dashboard-customizado.log
fase4/docs/evidencias/fase4-bloco32-grafana-dashboard-customizado.md
fase4/docs/evidencias/fase4-bloco33-10-loki-writable-final.log
fase4/docs/evidencias/fase4-bloco33-10-loki-writable-final.md
fase4/docs/evidencias/fase4-bloco33-12-promtail-logs-loki.log
fase4/docs/evidencias/fase4-bloco33-12-promtail-logs-loki.md
fase4/docs/evidencias/fase4-bloco33-1-loki-light-mode-fix.log
fase4/docs/evidencias/fase4-bloco33-2-loki-light-mode-v2.log
fase4/docs/evidencias/fase4-bloco33-2-loki-light-mode-v2.md
fase4/docs/evidencias/fase4-bloco33-4-cluster-stabilization-after-lab.log
fase4/docs/evidencias/fase4-bloco33-4-cluster-stabilization-after-lab.md
fase4/docs/evidencias/fase4-bloco33-6-loki-sync-prune.log
fase4/docs/evidencias/fase4-bloco33-6-loki-sync-prune.md
fase4/docs/evidencias/fase4-bloco33-7-loki-sync-prune-no-pyyaml.log
fase4/docs/evidencias/fase4-bloco33-7-loki-sync-prune-no-pyyaml.md
fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.log
fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md
fase4/docs/evidencias/fase4-bloco33-9-loki-var-writable-fix.log
fase4/docs/evidencias/fase4-bloco33-9-loki-var-writable-fix.md
fase4/docs/evidencias/fase4-bloco33-loki-promtail-argocd.log
fase4/docs/evidencias/fase4-bloco34-otel-collector.log
fase4/docs/evidencias/fase4-bloco34-otel-collector.md
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.log
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md
fase4/docs/evidencias/fase4-bloco35-10-figuras-newrelic-documento.md
fase4/docs/evidencias/fase4-bloco35-1-inventario-codigo-fluxo-apm.log
fase4/docs/evidencias/fase4-bloco35-1-inventario-codigo-fluxo-apm.md
fase4/docs/evidencias/fase4-bloco35-2-plano-instrumentacao-apm.md
fase4/docs/evidencias/fase4-bloco35-3-snapshot-cirurgico-tracing.md
fase4/docs/evidencias/fase4-bloco35-4-patch-otel-evaluation-flow.md
fase4/docs/evidencias/fase4-bloco35-5-build-local-imagens-otel.log
fase4/docs/evidencias/fase4-bloco35-5-build-local-imagens-otel.md
fase4/docs/evidencias/fase4-bloco35-6-push-ecr-rollout-otel.md
fase4/docs/evidencias/fase4-bloco35-7-validacao-traces-otel-collector.md
fase4/docs/evidencias/fase4-bloco35-8a-newrelic-otel-exporter.md
fase4/docs/evidencias/fase4-bloco35-8b-correcao-newrelic-otlp-403.md
fase4/docs/evidencias/fase4-bloco35-8d-validacao-newrelic-us-key.md
fase4/docs/evidencias/fase4-bloco35-9b-trafego-newrelic-apm.md
fase4/docs/evidencias/fase4-bloco36-1-checkpoint-geral-pos-apm.md
```

## Próximo passo recomendado
Implementar e evidenciar a cadeia de resposta ativa: alerta Firing -> incidente automático -> ChatOps -> self-healing.
