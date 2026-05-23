# ADR-001 - Estratégia Inicial da Fase 4

## Status

Proposta inicial.

## Contexto

A Fase 4 exige observabilidade total e resposta ativa sobre o ToggleMaster já implantado via IaC/GitOps/Kubernetes.

A base das Fases 2 e 3 foi validada antes do início da Fase 4.

## Decisão inicial

A implementação seguirá esta ordem:

1. Inventário e desenho da arquitetura de observabilidade.
2. GitOps/Helm para stack base: Prometheus, Loki, Grafana.
3. OpenTelemetry Collector.
4. Instrumentação progressiva dos microsserviços.
5. APM: Datadog ou New Relic.
6. Alerting e Incident Management.
7. ChatOps.
8. Self-Healing.
9. Prova real de incidente.
10. Relatório e vídeo.

## Decisões pendentes

- Escolha final entre Datadog e New Relic.
- Escolha final entre PagerDuty e OpsGenie.
- Canal ChatOps: Discord, Slack ou Teams.
- Forma final do self-healing: GitHub Action via webhook, Lambda, ou runbook automation.

## Critério

A escolha deve priorizar:

- compatibilidade com AWS Academy;
- menor risco operacional;
- capacidade de demonstrar no vídeo;
- clareza das evidências;
- aderência ao requisito oficial.
