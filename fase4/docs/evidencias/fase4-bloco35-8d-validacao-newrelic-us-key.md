# Fase 4 - BLOCO 35.8D - Validação New Relic com License Key US válida

Data: Sat May 23 07:02:46 PM -03 2026

## Objetivo
Aplicar a License Key correta do New Relic US em Kubernetes Secret, reiniciar o Collector e validar exportação sem HTTP 403.

## Segurança
A chave foi aplicada em Kubernetes Secret e não foi versionada no Git.

## Teste E2E
```text
FLAG_NAME=nr-ok-1779573688
USER_ID=nr-user-1779573688
CREATE_FLAG_HTTP=201
CREATE_RULE_HTTP=201
EVAL_HTTP=200
```

## Resposta evaluate
```json
{"flag_name":"nr-ok-1779573688","user_id":"nr-user-1779573688","result":true}

```

## Contadores Collector
```text
PERMISSION_DENIED_COUNT=0
EXPORTER_ERROR_COUNT=0
DEBUG_SPANS_COUNT=68
SERVICE_SPANS_COUNT=69
MARKER_COUNT=4
```

## Resultado
Exportação OTLP para New Relic validada sem erros 403/PermissionDenied no período observado.
