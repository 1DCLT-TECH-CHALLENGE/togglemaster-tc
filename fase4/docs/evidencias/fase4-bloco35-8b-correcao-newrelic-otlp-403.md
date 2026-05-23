# Fase 4 - BLOCO 35.8B - Correção New Relic OTLP 403

Data: Sat May 23 06:49:39 PM -03 2026

## Objetivo
Corrigir o erro HTTP 403 PermissionDenied do exporter otlphttp/newrelic.

## Diagnóstico anterior
O BLOCO 35.8A deixou o Collector saudável, mas o New Relic retornou HTTP 403/PermissionDenied.

## Correção aplicada
- License key atualizada em Kubernetes Secret newrelic-otel-secret, sem versionar segredo.
- Endpoint OTLP configurado: https://otlp.nr-data.net:4318

## Render Kustomize
```text
29:        endpoint: ${env:NEW_RELIC_OTLP_ENDPOINT}
128:        - name: NEW_RELIC_OTLP_ENDPOINT
31:          api-key: ${env:NEW_RELIC_LICENSE_KEY}
130:        - name: NEW_RELIC_LICENSE_KEY
```

## Teste E2E pós-correção
```text
FLAG_NAME=nr-trace-1779573024
USER_ID=nr-user-1779573024
CREATE_FLAG_HTTP=201
CREATE_RULE_HTTP=201
EVAL_HTTP=200
```

## Contadores do Collector
```text
PERMISSION_DENIED_COUNT=47
EXPORTER_ERROR_COUNT=47
DEBUG_SPANS_COUNT=47
SERVICE_SPANS_COUNT=47
```

## Resultado
Ainda há erro de exportação/autenticação para New Relic. Validar se a chave é Ingest - License e se a região/endpoint está correta.
