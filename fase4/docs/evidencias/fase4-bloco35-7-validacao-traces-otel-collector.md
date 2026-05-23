# Fase 4 - BLOCO 35.7 - Validação de traces reais no OTel Collector

Data: Sat May 23 06:30:05 PM -03 2026

## Objetivo
Gerar uma chamada real no fluxo evaluation-service -> flag-service -> targeting-service e validar spans no OpenTelemetry Collector.

## Fluxo executado
- Criação de flag única via flag-service.
- Criação de regra única via targeting-service.
- Chamada real em evaluation-service /evaluate.
- Coleta de logs recentes do otel-collector.

## IDs do teste
```text
FLAG_NAME=otel-trace-1779571757
USER_ID=otel-user-1779571757
```

## HTTP status
```text
CREATE_FLAG_HTTP=201
CREATE_RULE_HTTP=201
EVAL_HTTP=200
```

## Resposta /evaluate
```json
{"flag_name":"otel-trace-1779571757","user_id":"otel-user-1779571757","result":true}

```

## Contadores nos logs do OTel Collector
```text
EVAL_SPANS=57
FLAG_SPANS=59
TARGET_SPANS=58
ROUTE_EVALUATE=3
ROUTE_FLAGS=7
ROUTE_RULES=7
FLAG_MARKER_COUNT=4
```

## Pods e imagens usadas
```text
evaluation-service-57d59f7b64-sl594 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:otel-b4f0b5c 
evaluation-service-57d59f7b64-vfjlq 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:otel-b4f0b5c 
flag-service-6d964dcffb-fxtgh 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:otel-b4f0b5c 
flag-service-6d964dcffb-rb47f 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:otel-b4f0b5c 
targeting-service-599dc5ffd-28pwg 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c 
targeting-service-599dc5ffd-ftkhh 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c 
```

## Trechos relevantes do Collector
```text
### evaluation-service
7830-Resource SchemaURL: https://opentelemetry.io/schemas/1.40.0
7831-Resource attributes:
7832-     -> deployment.environment: Str(dev)
7833:     -> service.name: Str(togglemaster-evaluation-service)
7834-     -> service.namespace: Str(togglemaster)
7835-     -> telemetry.sdk.language: Str(go)
7836-     -> telemetry.sdk.name: Str(opentelemetry)
7837-     -> telemetry.sdk.version: Str(1.43.0)
7838-ScopeSpans #0
7839-ScopeSpans SchemaURL: 
--
7889-	{"kind": "exporter", "data_type": "traces", "name": "debug"}
7890-2026-05-23T21:29:36.647Z	info	TracesExporter	{"kind": "exporter", "data_type": "traces", "name": "debug", "resource spans": 1, "spans": 2}
7891-2026-05-23T21:29:36.647Z	info	ResourceSpans #0
7892-Resource SchemaURL: https://opentelemetry.io/schemas/1.40.0
7893-Resource attributes:
7894-     -> deployment.environment: Str(dev)
7895:     -> service.name: Str(togglemaster-evaluation-service)
7896-     -> service.namespace: Str(togglemaster)
7897-     -> telemetry.sdk.language: Str(go)
7898-     -> telemetry.sdk.name: Str(opentelemetry)
7899-     -> telemetry.sdk.version: Str(1.43.0)
7900-ScopeSpans #0
7901-ScopeSpans SchemaURL: 
--
8151-	{"kind": "exporter", "data_type": "traces", "name": "debug"}
8152-2026-05-23T21:29:45.679Z	info	TracesExporter	{"kind": "exporter", "data_type": "traces", "name": "debug", "resource spans": 1, "spans": 1}
8153-2026-05-23T21:29:45.679Z	info	ResourceSpans #0
8154-Resource SchemaURL: https://opentelemetry.io/schemas/1.40.0
8155-Resource attributes:
8156-     -> deployment.environment: Str(dev)
8157:     -> service.name: Str(togglemaster-evaluation-service)
8158-     -> service.namespace: Str(togglemaster)
8159-     -> telemetry.sdk.language: Str(go)
8160-     -> telemetry.sdk.name: Str(opentelemetry)
8161-     -> telemetry.sdk.version: Str(1.43.0)
8162-ScopeSpans #0
8163-ScopeSpans SchemaURL: 
--
8189-	{"kind": "exporter", "data_type": "traces", "name": "debug"}
8190-2026-05-23T21:29:46.482Z	info	TracesExporter	{"kind": "exporter", "data_type": "traces", "name": "debug", "resource spans": 1, "spans": 1}
8191-2026-05-23T21:29:46.482Z	info	ResourceSpans #0
8192-Resource SchemaURL: https://opentelemetry.io/schemas/1.40.0
8193-Resource attributes:
8194-     -> deployment.environment: Str(dev)
8195:     -> service.name: Str(togglemaster-evaluation-service)
8196-     -> service.namespace: Str(togglemaster)
8197-     -> telemetry.sdk.language: Str(go)
8198-     -> telemetry.sdk.name: Str(opentelemetry)
8199-     -> telemetry.sdk.version: Str(1.43.0)
8200-ScopeSpans #0
8201-ScopeSpans SchemaURL: 
--
8427-	{"kind": "exporter", "data_type": "traces", "name": "debug"}
8428-2026-05-23T21:29:55.827Z	info	TracesExporter	{"kind": "exporter", "data_type": "traces", "name": "debug", "resource spans": 1, "spans": 2}
8429-2026-05-23T21:29:55.827Z	info	ResourceSpans #0
8430-Resource SchemaURL: https://opentelemetry.io/schemas/1.40.0
8431-Resource attributes:
8432-     -> deployment.environment: Str(dev)
8433:     -> service.name: Str(togglemaster-evaluation-service)
8434-     -> service.namespace: Str(togglemaster)
8435-     -> telemetry.sdk.language: Str(go)
8436-     -> telemetry.sdk.name: Str(opentelemetry)
8437-     -> telemetry.sdk.version: Str(1.43.0)
8438-ScopeSpans #0
8439-ScopeSpans SchemaURL: 
--
8489-	{"kind": "exporter", "data_type": "traces", "name": "debug"}
8490-2026-05-23T21:29:56.644Z	info	TracesExporter	{"kind": "exporter", "data_type": "traces", "name": "debug", "resource spans": 1, "spans": 2}
8491-2026-05-23T21:29:56.644Z	info	ResourceSpans #0
8492-Resource SchemaURL: https://opentelemetry.io/schemas/1.40.0
8493-Resource attributes:
8494-     -> deployment.environment: Str(dev)
8495:     -> service.name: Str(togglemaster-evaluation-service)
8496-     -> service.namespace: Str(togglemaster)
8497-     -> telemetry.sdk.language: Str(go)
8498-     -> telemetry.sdk.name: Str(opentelemetry)
8499-     -> telemetry.sdk.version: Str(1.43.0)
8500-ScopeSpans #0
8501-ScopeSpans SchemaURL: 

### flag-service
7958-     -> telemetry.sdk.version: Str(1.27.0)
7959-     -> service.namespace: Str(togglemaster)
7960-     -> deployment.environment: Str(dev)
7961:     -> service.name: Str(togglemaster-flag-service)
7962-ScopeSpans #0
7963-ScopeSpans SchemaURL: 
7964-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
7965-Span #0
7966-    Trace ID       : 49521e5f74f3e1a9d5a76f4f0ebb22c9
7967-    Parent ID      : 
--
8079-Resource attributes:
8080-     -> telemetry.sdk.language: Str(python)
8081-     -> telemetry.sdk.name: Str(opentelemetry)
8082-     -> telemetry.sdk.version: Str(1.27.0)
8083-     -> service.namespace: Str(togglemaster)
8084-     -> deployment.environment: Str(dev)
8085:     -> service.name: Str(togglemaster-flag-service)
8086-ScopeSpans #0
8087-ScopeSpans SchemaURL: 
8088-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8089-Span #0
8090-    Trace ID       : 7685829606053638b4bf27d240edb5b3
8091-    Parent ID      : 
--
8231-Resource attributes:
8232-     -> telemetry.sdk.language: Str(python)
8233-     -> telemetry.sdk.name: Str(opentelemetry)
8234-     -> telemetry.sdk.version: Str(1.27.0)
8235-     -> service.namespace: Str(togglemaster)
8236-     -> deployment.environment: Str(dev)
8237:     -> service.name: Str(togglemaster-flag-service)
8238-ScopeSpans #0
8239-ScopeSpans SchemaURL: 
8240-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8241-Span #0
8242-    Trace ID       : c7051fef1bd6c5ee57031fe626dd77d9
8243-    Parent ID      : 
--
8307-Resource attributes:
8308-     -> telemetry.sdk.language: Str(python)
8309-     -> telemetry.sdk.name: Str(opentelemetry)
8310-     -> telemetry.sdk.version: Str(1.27.0)
8311-     -> service.namespace: Str(togglemaster)
8312-     -> deployment.environment: Str(dev)
8313:     -> service.name: Str(togglemaster-flag-service)
8314-ScopeSpans #0
8315-ScopeSpans SchemaURL: 
8316-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8317-Span #0
8318-    Trace ID       : abf821754550968ae1945c386f8f25ba
8319-    Parent ID      : 
--
8555-Resource attributes:
8556-     -> telemetry.sdk.language: Str(python)
8557-     -> telemetry.sdk.name: Str(opentelemetry)
8558-     -> telemetry.sdk.version: Str(1.27.0)
8559-     -> service.namespace: Str(togglemaster)
8560-     -> deployment.environment: Str(dev)
8561:     -> service.name: Str(togglemaster-flag-service)
8562-ScopeSpans #0
8563-ScopeSpans SchemaURL: 
8564-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8565-Span #0
8566-    Trace ID       : 7e2569c2efa04456eb915336a8d127f4
8567-    Parent ID      : 
--
8679-Resource attributes:
8680-     -> telemetry.sdk.language: Str(python)
8681-     -> telemetry.sdk.name: Str(opentelemetry)
8682-     -> telemetry.sdk.version: Str(1.27.0)
8683-     -> service.namespace: Str(togglemaster)
8684-     -> deployment.environment: Str(dev)
8685:     -> service.name: Str(togglemaster-flag-service)
8686-ScopeSpans #0
8687-ScopeSpans SchemaURL: 
8688-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8689-Span #0
8690-    Trace ID       : dd7a2f86c5b02376e8e1ce539ebf5203
8691-    Parent ID      : 

### targeting-service
8020-     -> telemetry.sdk.version: Str(1.27.0)
8021-     -> service.namespace: Str(togglemaster)
8022-     -> deployment.environment: Str(dev)
8023:     -> service.name: Str(togglemaster-targeting-service)
8024-ScopeSpans #0
8025-ScopeSpans SchemaURL: 
8026-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8027-Span #0
8028-    Trace ID       : ee777a7f2434c86a50912ff81a83898d
8029-    Parent ID      : 
--
8117-Resource attributes:
8118-     -> telemetry.sdk.language: Str(python)
8119-     -> telemetry.sdk.name: Str(opentelemetry)
8120-     -> telemetry.sdk.version: Str(1.27.0)
8121-     -> service.namespace: Str(togglemaster)
8122-     -> deployment.environment: Str(dev)
8123:     -> service.name: Str(togglemaster-targeting-service)
8124-ScopeSpans #0
8125-ScopeSpans SchemaURL: 
8126-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8127-Span #0
8128-    Trace ID       : 4a32dbe9358e659703d25763e242acb7
8129-    Parent ID      : 
--
8269-Resource attributes:
8270-     -> telemetry.sdk.language: Str(python)
8271-     -> telemetry.sdk.name: Str(opentelemetry)
8272-     -> telemetry.sdk.version: Str(1.27.0)
8273-     -> service.namespace: Str(togglemaster)
8274-     -> deployment.environment: Str(dev)
8275:     -> service.name: Str(togglemaster-targeting-service)
8276-ScopeSpans #0
8277-ScopeSpans SchemaURL: 
8278-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8279-Span #0
8280-    Trace ID       : fddc3ca1991b4f52bbf42735a6a4b873
8281-    Parent ID      : 
--
8369-Resource attributes:
8370-     -> telemetry.sdk.language: Str(python)
8371-     -> telemetry.sdk.name: Str(opentelemetry)
8372-     -> telemetry.sdk.version: Str(1.27.0)
8373-     -> service.namespace: Str(togglemaster)
8374-     -> deployment.environment: Str(dev)
8375:     -> service.name: Str(togglemaster-targeting-service)
8376-ScopeSpans #0
8377-ScopeSpans SchemaURL: 
8378-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8379-Span #0
8380-    Trace ID       : 8ef4811030edca772b5b1258a39fc99c
8381-    Parent ID      : 
--
8617-Resource attributes:
8618-     -> telemetry.sdk.language: Str(python)
8619-     -> telemetry.sdk.name: Str(opentelemetry)
8620-     -> telemetry.sdk.version: Str(1.27.0)
8621-     -> service.namespace: Str(togglemaster)
8622-     -> deployment.environment: Str(dev)
8623:     -> service.name: Str(togglemaster-targeting-service)
8624-ScopeSpans #0
8625-ScopeSpans SchemaURL: 
8626-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8627-Span #0
8628-    Trace ID       : 2d356f0af1242a5c794a9cebb6649a36
8629-    Parent ID      : 
--
8717-Resource attributes:
8718-     -> telemetry.sdk.language: Str(python)
8719-     -> telemetry.sdk.name: Str(opentelemetry)
8720-     -> telemetry.sdk.version: Str(1.27.0)
8721-     -> service.namespace: Str(togglemaster)
8722-     -> deployment.environment: Str(dev)
8723:     -> service.name: Str(togglemaster-targeting-service)
8724-ScopeSpans #0
8725-ScopeSpans SchemaURL: 
8726-InstrumentationScope opentelemetry.instrumentation.flask 0.48b0
8727-Span #0
8728-    Trace ID       : 7f7f4569354eec74f5be06ad4b60531e
8729-    Parent ID      : 
```

## Resultado
O OTel Collector recebeu spans dos três serviços instrumentados no fluxo de avaliação.
