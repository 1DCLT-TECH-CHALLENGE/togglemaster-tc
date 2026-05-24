# Fase 4 - BLOCO 38.3 - ChatOps Discord

Data: Sat May 23 09:58:43 PM -03 2026

## Objetivo
Validar a notificação ChatOps no Discord a partir de um alerta Prometheus/Alertmanager.

## Alerta utilizado
```text
alertname=ToggleMasterPhase4ChatOpsFiring
state=firing
severity=warning
component=togglemaster
namespace=observability
chatops_only=enabled
incident_chain=enabled
activeAt=2026-05-24T00:57:58.332050143Z
```

## Estado ArgoCD
```text
NAME                            SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-alerting          Synced        Healthy         fb6eaa2dbae085af4484371e757d22f3e59923a2   default
observability-incident-bridge   Synced        Healthy         fb6eaa2dbae085af4484371e757d22f3e59923a2   default
```

## Logs sanitizados do incident bridge
```text
2026-05-24T00:56:42Z starting_incident_bridge port=8080
2026-05-24T00:57:35Z processed_alert=ToggleMasterPhase4ValidationFiring status=firing
2026-05-24T00:57:35Z pagerduty_status=202 dedup_key=togglemaster-fase4-ToggleMasterPhase4ValidationFiring-togglemaster body={"dedup_key":"togglemaster-fase4-ToggleMasterPhase4ValidationFiring-togglemaster","message":"Event processed","status":"
2026-05-24T00:57:35Z discord_status=204 alertname=ToggleMasterPhase4ValidationFiring body=
2026-05-24T00:57:35Z processed_alert=ToggleMasterPhase4IncidentBridgeFiring status=firing
2026-05-24T00:57:35Z pagerduty_status=202 dedup_key=togglemaster-fase4-ToggleMasterPhase4IncidentBridgeFiring-togglemaster body={"dedup_key":"togglemaster-fase4-ToggleMasterPhase4IncidentBridgeFiring-togglemaster","message":"Event processed","statu
2026-05-24T00:57:36Z discord_status=204 alertname=ToggleMasterPhase4IncidentBridgeFiring body=
2026-05-24T00:58:33Z processed_alert=ToggleMasterPhase4ChatOpsFiring status=firing
2026-05-24T00:58:33Z pagerduty_status=skipped_chatops_only
2026-05-24T00:58:33Z discord_status=204 alertname=ToggleMasterPhase4ChatOpsFiring body=
```

## Resultado
O alerta ChatOps foi recebido pelo incident bridge e a mensagem foi enviada ao Discord com sucesso.

## Próxima figura
- Figura 12: notificação ChatOps recebida no Discord.
