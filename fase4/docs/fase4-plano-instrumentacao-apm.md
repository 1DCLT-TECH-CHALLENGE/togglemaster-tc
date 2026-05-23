# Plano de Instrumentacao APM/tracing - Fase 4

## Objetivo
Instrumentar os cinco microsservicos ToggleMaster para gerar traces reais, service map e trace distribuido.

## Fluxo principal escolhido
cliente de teste -> evaluation-service /evaluate -> flag-service /flags/<flag_name> -> targeting-service /rules/<flag_name>

## Estrategia
1. Instrumentar primeiro o fluxo de avaliacao.
2. Comecar por evaluation-service como ponto de entrada.
3. Instrumentar flag-service e targeting-service para compor trace distribuido.
4. Adicionar auth-service e analytics-service para completar a cobertura dos cinco servicos.
5. Configurar variaveis OTEL nos manifests GitOps.
6. Buildar e publicar novas imagens.
7. Atualizar tags no GitOps.
8. Validar health checks e fluxo funcional.
9. Validar spans no OTel Collector.
10. Integrar Datadog ou New Relic pelo Collector.
11. Capturar Figura 7 - Service map.
12. Capturar Figura 8 - Trace distribuido.

## Variaveis planejadas
- OTEL_SERVICE_NAME
- OTEL_EXPORTER_OTLP_ENDPOINT
- OTEL_EXPORTER_OTLP_PROTOCOL
- OTEL_TRACES_EXPORTER
- OTEL_METRICS_EXPORTER
- OTEL_LOGS_EXPORTER
- OTEL_RESOURCE_ATTRIBUTES

## Endpoint interno
http://otel-collector.observability.svc.cluster.local:4318

## Arquivos previstos para alteracao
- fase2/src/services/evaluation-service/*
- fase2/src/services/auth-service/*
- fase2/src/services/flag-service/*
- fase2/src/services/targeting-service/*
- fase2/src/services/analytics-service/*
- fase3/gitops/base/*-service.yaml
- fase3/gitops/base/configmap.yaml
- fase3/gitops/overlays/dev/kustomization.yaml

## Evidencias futuras
- Logs do OTel Collector recebendo spans reais.
- APM com service map.
- APM com trace distribuido.
