# Fase 4 - Matriz de Requisitos, Evidências e DoD

## Premissa

A Fase 4 começa após validação funcional das Fases 2 e 3. O gate oficial está registrado em:

- `_shared/evidencias/gate-pre-fase4-fases2-3.md`

## Requisitos oficiais e critérios de aceite

| ID | Requisito | Implementação esperada | Evidência obrigatória | Status |
|---|---|---|---|---|
| F4-01 | Prometheus | Instalação via GitOps/Helm no EKS | Pods/Service/targets ativos e métricas consultáveis | Pendente |
| F4-02 | Loki | Logs centralizados dos containers | Consulta no Grafana/Loki mostrando logs dos microsserviços | Pendente |
| F4-03 | Grafana | Dashboard customizado | Print/dashboard com saúde do cluster, requests dos microsserviços e logs em tempo real | Pendente |
| F4-04 | OpenTelemetry Collector | Collector recebendo/processando/exportando telemetria | Manifests, pods e fluxo documentado | Pendente |
| F4-05 | Instrumentação dos 5 serviços | Bibliotecas/configuração OTel nos serviços | Requisições gerando métricas/traces/logs | Pendente |
| F4-06 | APM | Datadog ou New Relic | Service Map e trace distribuído de requisição real | Pendente |
| F4-07 | Alertas inteligentes | Alerta por erro/latência/5xx | Estado Firing demonstrado | Pendente |
| F4-08 | Incident Management | PagerDuty ou OpsGenie | Incidente aberto automaticamente | Pendente |
| F4-09 | ChatOps | Slack/Discord/Teams | Notificação recebida no canal | Pendente |
| F4-10 | Self-Healing | Automação via runbook/Lambda/GitHub Action/webhook | Execução corretiva demonstrada, ex.: rollout restart | Pendente |
| F4-11 | Prova real de incidente | Falha provocada de forma controlada | Cadeia completa: erro -> alerta -> incidente -> ChatOps -> self-healing | Pendente |
| F4-12 | Relatório final PDF | Documento de entrega | PDF com links, prints e justificativas técnicas | Pendente |
| F4-13 | Vídeo até 25 min | Demonstração completa | Link do vídeo com evidências operando | Pendente |

## Definition of Done da Fase 4

A Fase 4 só será considerada pronta quando todos os itens abaixo estiverem completos:

1. Stack de observabilidade implantada via GitOps.
2. Prometheus, Loki, Grafana e OTel Collector operando no cluster.
3. Pelo menos 1 dashboard customizado no Grafana.
4. Os 5 microsserviços instrumentados ou integrados ao pipeline de telemetria.
5. APM exibindo Service Map e trace distribuído.
6. Alerta configurado e demonstrado em estado Firing.
7. Incidente aberto automaticamente em PagerDuty ou OpsGenie.
8. Notificação recebida em canal ChatOps.
9. Self-healing executando ação corretiva real.
10. Evidências coletadas.
11. Relatório PDF produzido.
12. Roteiro e vídeo final preparados.
13. Código, manifests, scripts e docs versionados no GitHub.
