# Fase 4 - BLOCO 35.4 - Patch OpenTelemetry no fluxo de avaliação

Data: Sat May 23 06:05:44 PM -03 2026

## Objetivo
Aplicar o primeiro patch real de instrumentação OpenTelemetry no fluxo evaluation-service -> flag-service -> targeting-service.

## Alterações
- evaluation-service recebeu helper OpenTelemetry, instrumentação HTTP server e client e propagação de contexto.
- flag-service recebeu helper OpenTelemetry Flask/requests.
- targeting-service recebeu helper OpenTelemetry Flask/requests.
- manifests GitOps receberam variáveis OTEL não sensíveis.

## Validações executadas
- gofmt no evaluation-service.
- go mod tidy e go build ./... no evaluation-service.
- py_compile nos serviços Python alterados.
- kubectl kustomize na base e no overlay dev.

## Arquivos alterados
```text
fase2/src/services/evaluation-service/evaluator.go
fase2/src/services/evaluation-service/go.mod
fase2/src/services/evaluation-service/go.sum
fase2/src/services/evaluation-service/handlers.go
fase2/src/services/evaluation-service/main.go
fase2/src/services/flag-service/app.py
fase2/src/services/flag-service/requirements.txt
fase2/src/services/targeting-service/app.py
fase2/src/services/targeting-service/requirements.txt
fase3/gitops/base/configmap.yaml
fase3/gitops/base/evaluation-service.yaml
fase3/gitops/base/flag-service.yaml
fase3/gitops/base/targeting-service.yaml
```

## Diff stat
```text
 fase2/src/services/evaluation-service/evaluator.go | 23 ++++----
 fase2/src/services/evaluation-service/go.mod       | 29 +++++++--
 fase2/src/services/evaluation-service/go.sum       | 69 ++++++++++++++++++----
 fase2/src/services/evaluation-service/handlers.go  |  2 +-
 fase2/src/services/evaluation-service/main.go      |  8 ++-
 fase2/src/services/flag-service/app.py             |  2 +
 fase2/src/services/flag-service/requirements.txt   |  5 ++
 fase2/src/services/targeting-service/app.py        |  2 +
 .../services/targeting-service/requirements.txt    |  5 ++
 fase3/gitops/base/configmap.yaml                   |  7 +++
 fase3/gitops/base/evaluation-service.yaml          |  2 +
 fase3/gitops/base/flag-service.yaml                |  2 +
 fase3/gitops/base/targeting-service.yaml           |  2 +
 13 files changed, 128 insertions(+), 30 deletions(-)
```

## Próximo passo
Buildar e publicar novas imagens dos serviços alterados, atualizar GitOps com nova tag e validar traces chegando ao OTel Collector.
