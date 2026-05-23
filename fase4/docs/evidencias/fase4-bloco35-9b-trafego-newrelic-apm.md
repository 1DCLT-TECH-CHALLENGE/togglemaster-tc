# Fase 4 - BLOCO 35.9B - Tráfego para visualização no New Relic APM

Data: Sat May 23 07:06:40 PM -03 2026

## Objetivo
Registrar a geração de tráfego real para popular o New Relic APM antes da captura das figuras de Service Map e Trace distribuído.

## Marcador do teste
```text
FLAG_NAME=nr-ui-1779573839
```

## Resultado das chamadas /evaluate
```text
i=1 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-1","result":true}
i=2 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-2","result":true}
i=3 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-3","result":true}
i=4 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-4","result":true}
i=5 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-5","result":true}
i=6 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-6","result":false}
i=7 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-7","result":false}
i=8 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-8","result":false}
i=9 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-9","result":false}
i=10 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-10","result":false}
i=11 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-11","result":false}
i=12 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-12","result":true}
i=13 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-13","result":false}
i=14 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-14","result":true}
i=15 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-15","result":true}
i=16 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-16","result":false}
i=17 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-17","result":true}
i=18 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-18","result":false}
i=19 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-19","result":false}
i=20 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-20","result":false}
i=21 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-21","result":true}
i=22 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-22","result":false}
i=23 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-23","result":false}
i=24 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-24","result":true}
i=25 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-25","result":false}
i=26 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-26","result":true}
i=27 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-27","result":false}
i=28 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-28","result":false}
i=29 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-29","result":false}
i=30 HTTP_CODE=200 RESULT={"flag_name":"nr-ui-1779573839","user_id":"nr-ui-user-1779573839-30","result":true}
```

## Estado das aplicações
```text
NAME                           SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-otel-collector   Synced        Healthy         b622cf4f15fa89a52fddf099231d986f89bae6cb   default
togglemaster-dev               Synced        Healthy         b622cf4f15fa89a52fddf099231d986f89bae6cb   default
```

## Pod do OTel Collector
```text
NAME                                                        READY   STATUS    RESTARTS   AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
otel-collector-79c4cc4ff7-lbxht                             1/1     Running   0          5m51s   10.10.58.123   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Contadores recentes do Collector
```text
PERMISSION_DENIED_COUNT=0
EXPORTER_ERROR_COUNT=0
SERVICE_SPANS_COUNT=213
```

## Consulta sugerida no New Relic
```sql
SELECT count(*) FROM Span WHERE service.name LIKE 'togglemaster%' FACET service.name SINCE 60 minutes ago
```

## Próximas evidências visuais
- Figura 7: Service Map/APM no New Relic.
- Figura 8: Trace distribuído real no New Relic.
