# ADR-005 - Instrumentacao APM/tracing distribuido da Fase 4

## Status
Aprovada para implementacao incremental.

## Contexto
A Fase 4 exige instrumentacao dos microsservicos, distributed tracing, service map e evidencia visual no APM.
O ambiente atual ja possui EKS, ArgoCD/GitOps, Prometheus/Grafana, Loki/Promtail e OpenTelemetry Collector operando.
Os blocos 35.0 e 35.1 confirmaram que os microsservicos ainda nao possuem instrumentacao OpenTelemetry evidente.
O fluxo principal passa pelo evaluation-service, que consulta flag-service e targeting-service.

## Decisao
A instrumentacao sera implementada com OpenTelemetry de forma incremental e vendor-neutral.
Os servicos enviarao telemetria para o OTel Collector interno em http://otel-collector.observability.svc.cluster.local:4318.
A exportacao para Datadog ou New Relic sera feita pelo Collector, nao diretamente pelos microsservicos.

## Servicos
| Servico | Linguagem | Estrategia |
|---|---|---|
| auth-service | Go | OTel SDK e instrumentacao HTTP server |
| evaluation-service | Go | OTel SDK, HTTP server/client e propagacao tracecontext |
| flag-service | Python | OTel Flask e requests |
| targeting-service | Python | OTel Flask e requests |
| analytics-service | Python | OTel basico e evolucao futura do fluxo assincrono |

## Criterios de aceite
- Deployments com variaveis OTEL explicitas.
- Fluxo /evaluate gerando traces reais.
- Propagacao de contexto entre servicos.
- OTel Collector recebendo spans das aplicacoes.
- APM exibindo service map.
- APM exibindo trace distribuido real.

## Seguranca
Nenhum token de Datadog ou New Relic sera versionado no Git.
Segredos devem ser tratados via Kubernetes Secret ou mecanismo equivalente.
