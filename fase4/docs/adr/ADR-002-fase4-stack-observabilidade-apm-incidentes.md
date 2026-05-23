# ADR-002 - Stack Inicial de Observabilidade, APM, Incidentes e Self-Healing

## Status

Proposta controlada para implementação.

## Contexto

A Fase 4 exige observabilidade total e resposta ativa sobre a base das Fases 2 e 3 já validada.

O PDF oficial exige:

- Prometheus, Grafana e Loki no Kubernetes.
- OpenTelemetry Collector obrigatório.
- Instrumentação dos microsserviços.
- APM com Datadog ou New Relic.
- Alerta inteligente.
- Incidente em PagerDuty ou OpsGenie.
- ChatOps em Slack, Discord ou Teams.
- Self-healing demonstrável.
- Evidências em vídeo e relatório.

## Decisão inicial

1. Stack open source no cluster:
   - Prometheus para métricas.
   - Loki para logs.
   - Grafana para dashboard e visualização.
   - OpenTelemetry Collector como hub obrigatório.

2. Instalação:
   - Preferência por Helm charts e manifests GitOps versionados.
   - Nada será aplicado manualmente sem evidência e documentação.

3. APM:
   - Decisão pendente entre Datadog e New Relic.
   - A escolha será feita após validar disponibilidade de conta gratuita/token e melhor viabilidade no AWS Academy.

4. Incidentes:
   - Decisão pendente entre PagerDuty e OpsGenie.
   - A escolha será feita após validar conta e integração com alerta.

5. ChatOps:
   - Decisão pendente entre Discord, Slack e Teams.
   - A escolha será feita após validar webhook/canal disponível.

6. Self-healing:
   - Preferência por automação segura e demonstrável.
   - Candidatos:
     - script versionado acionado por webhook;
     - GitHub Action workflow_dispatch/repository_dispatch;
     - runbook automation;
     - Lambda somente se não criar conflito com AWS Academy/LabRole.

## Consequências

- O próximo passo é instalar a stack open source base via GitOps.
- APM, incidentes e ChatOps dependem de credenciais/tokens externos e serão tratados sem versionar segredos.
- Todo requisito só será considerado concluído após demonstração prática.
