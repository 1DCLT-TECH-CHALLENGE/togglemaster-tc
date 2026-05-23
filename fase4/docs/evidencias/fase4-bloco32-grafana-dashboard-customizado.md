# Fase 4 - BLOCO 32 - Dashboard Customizado do Grafana

Data: Sat May 23 04:05:18 PM -03 2026

## Objetivo

Aplicar e validar o dashboard customizado do ToggleMaster no Grafana, usando GitOps/ArgoCD.

Este bloco:

- aplica a ArgoCD Application `observability-dashboards`;
- valida o ConfigMap do dashboard;
- valida que o Grafana importou o dashboard;
- não expõe senha do Grafana na evidência.


## Resultado

- Application ArgoCD: `observability-dashboards`
- Application status: `Synced/Healthy`
- ConfigMap: `togglemaster-grafana-dashboard`
- Label do ConfigMap: `grafana_dashboard=1`
- Dashboard ToggleMaster encontrado no Grafana: `true`

### Application

```text
NAME                       SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-dashboards   Synced        Healthy         19aa77ce94595ff76b561e9a6240420779f03c21   default
```

### ConfigMap

```text
NAME                             DATA   AGE
togglemaster-grafana-dashboard   1      14s
```

### Dashboard encontrado

```text
CUSTOM_DASHBOARD_FOUND=true
title=ToggleMaster - Observability Overview
uid=togglemaster-ecosystem
folder=None
```

### Grafana health

```json
{
  "database": "ok",
  "version": "13.0.1+security-01",
  "commit": "9bbe672d"
}
```
