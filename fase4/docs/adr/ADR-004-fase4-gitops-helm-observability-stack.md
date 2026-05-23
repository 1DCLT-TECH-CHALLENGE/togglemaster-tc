# ADR-004 - GitOps e Helm para Stack Base de Observabilidade

## Status

Proposta preparada para aplicação em bloco posterior.

## Contexto

A Fase 4 exige uma stack open source com Prometheus, Grafana e Loki no Kubernetes, além do OpenTelemetry Collector como componente obrigatório.

Após o BLOCO 28, o cluster possui capacidade suficiente para iniciar a instalação controlada.

## Decisão

Preparar a stack usando GitOps/ArgoCD e Helm charts versionados:

- `kube-prometheus-stack` para Prometheus, Grafana, Alertmanager, kube-state-metrics e node-exporter;
- `loki` para centralização de logs;
- `promtail` para coleta de logs dos pods;
- `opentelemetry-collector` para receber telemetria OTLP e expor métricas;
- dashboard customizado inicial do ToggleMaster carregado via ConfigMap.

## Versões selecionadas no BLOCO 29

- kube-prometheus-stack: `85.3.0`
- loki: `7.0.0`
- promtail: `6.17.1`
- opentelemetry-collector: `0.156.2`

## Consequências

- Este bloco não instala nada.
- O próximo bloco deve aplicar os ArgoCD Applications em ordem controlada.
- Após a instalação, será necessário validar pods, services, targets, Grafana, Loki e OTel.
- A instrumentação dos microsserviços será tratada em blocos posteriores.
