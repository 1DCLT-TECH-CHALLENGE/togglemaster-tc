# ToggleMaster - Fase 4 - Observabilidade Total e Resposta Ativa

## Status

Fase 4 iniciada oficialmente após gate consolidado pré-Fase 4.

A Fase 4 **não é rebuild**. Ela parte da base funcional das Fases 2 e 3:

- Fase 2 local revalidada.
- Fase 3 cloud revalidada.
- EKS, ArgoCD, GitOps, microsserviços, SQS, DynamoDB e fluxo funcional validados.
- Gate pré-Fase 4 registrado em `_shared/evidencias/gate-pre-fase4-fases2-3.md`.

## Objetivo

Implementar observabilidade total e resposta ativa sobre o ecossistema ToggleMaster.

## Escopo técnico

- Prometheus para métricas.
- Loki para logs centralizados.
- Grafana para dashboard customizado.
- OpenTelemetry Collector como ponto central de telemetria.
- Instrumentação dos 5 microsserviços.
- APM com Datadog ou New Relic.
- Alertas inteligentes.
- Integração com PagerDuty ou OpsGenie.
- Notificação ChatOps.
- Automação de self-healing.
- Evidências visuais e roteiro de vídeo.
- Relatório final em PDF.

## Regra operacional

Nenhuma implementação será considerada concluída apenas por estar configurada.
Cada requisito precisa ser demonstrado funcionando na prática.

<!-- TOGGLEMASTER_FINAL_NAV_START -->
## Reprodutibilidade da Fase 4

Escopo: observabilidade, métricas, logs, APM, alertas, incidentes, ChatOps e self-healing sobre a Fase 3.

Comando principal:

`NEW_RELIC_LICENSE_KEY="..." PAGERDUTY_ROUTING_KEY="..." DISCORD_WEBHOOK_URL="..." ./bootstraps/04_bootstrap_fase4.sh`

Observação: secrets reais não são versionados. Integrações externas devem ser configuradas por variáveis de ambiente, Kubernetes Secrets ou mecanismo seguro equivalente.
<!-- TOGGLEMASTER_FINAL_NAV_END -->
