# Fase 4 - BLOCO 35.2 - Plano de instrumentacao APM/tracing

Data: Sat May 23 05:57:23 PM -03 2026

## Objetivo
Registrar a decisao tecnica e o plano operacional para instrumentacao OpenTelemetry antes de alterar codigo, Dockerfiles, dependencias, imagens e manifests.

## Resultado
- ADR: fase4/docs/adr/ADR-005-fase4-instrumentacao-apm-tracing.md
- Plano: fase4/docs/fase4-plano-instrumentacao-apm.md

## Decisao
A instrumentacao sera feita com OpenTelemetry vendor-neutral, enviando telemetria para o OTel Collector interno.
A exportacao para Datadog ou New Relic sera feita pelo Collector.

## Criterio de continuidade
O proximo bloco podera iniciar a alteracao real de codigo para gerar traces no fluxo evaluation-service -> flag-service -> targeting-service.

## Imagens
Nenhuma imagem deve ser capturada neste bloco.
As imagens relacionadas serao Figura 7 - Service map do APM e Figura 8 - Trace distribuido.
