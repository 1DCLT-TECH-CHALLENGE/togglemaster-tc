# Fase 4 - BLOCO 35.8A - New Relic OTLP exporter no OTel Collector

Data: Sat May 23 06:42:22 PM -03 2026

## Objetivo
Integrar o OpenTelemetry Collector ao New Relic APM via OTLP/HTTP, sem versionar segredo.

## Decisão
O Collector passa a exportar traces para New Relic usando o exporter otlphttp/newrelic.

## Segurança
A New Relic License Key foi criada em Kubernetes Secret newrelic-otel-secret e não foi versionada no Git.

## Endpoint
https://otlp.nr-data.net:4318

## Render Kustomize
```text
28:      otlphttp/newrelic:
50:            - otlphttp/newrelic
29:        endpoint: ${env:NEW_RELIC_OTLP_ENDPOINT}
128:        - name: NEW_RELIC_OTLP_ENDPOINT
```
