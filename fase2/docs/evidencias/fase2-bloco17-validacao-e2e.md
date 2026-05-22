# Fase 2 - BLOCO 17 - Validação Funcional End-to-End

Data: Fri May 22 01:29:08 PM -03 2026

## Objetivo
Validar a Fase 2 local de ponta a ponta: auth, flag, targeting, evaluation, Redis, SQS LocalStack, analytics-service e DynamoDB LocalStack.

NAME                          IMAGE                         COMMAND                  SERVICE              CREATED              STATUS                        PORTS
docker-analytics-service-1    docker-analytics-service      "gunicorn --bind 0.0…"   analytics-service    About a minute ago   Up About a minute             0.0.0.0:8005->8000/tcp, [::]:8005->8000/tcp
docker-auth-service-1         docker-auth-service           "/app/service"           auth-service         About a minute ago   Up About a minute             0.0.0.0:8001->8000/tcp, [::]:8001->8000/tcp
docker-evaluation-service-1   docker-evaluation-service     "/app/service"           evaluation-service   About a minute ago   Up About a minute             0.0.0.0:8004->8000/tcp, [::]:8004->8000/tcp
docker-flag-service-1         docker-flag-service           "gunicorn --bind 0.0…"   flag-service         About a minute ago   Up About a minute             0.0.0.0:8002->8000/tcp, [::]:8002->8000/tcp
docker-localstack-1           localstack/localstack:3.8.1   "docker-entrypoint.sh"   localstack           About a minute ago   Up About a minute (healthy)   4510-4559/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp, [::]:4566->4566/tcp
docker-postgres-auth-1        postgres:13                   "docker-entrypoint.s…"   postgres-auth        About a minute ago   Up About a minute             0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp
docker-postgres-flags-1       postgres:13                   "docker-entrypoint.s…"   postgres-flags       About a minute ago   Up About a minute             0.0.0.0:5434->5432/tcp, [::]:5434->5432/tcp
docker-postgres-targeting-1   postgres:13                   "docker-entrypoint.s…"   postgres-targeting   About a minute ago   Up About a minute             0.0.0.0:5435->5432/tcp, [::]:5435->5432/tcp
docker-redis-1                redis:7-alpine                "docker-entrypoint.s…"   redis                About a minute ago   Up About a minute             0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
docker-targeting-service-1    docker-targeting-service      "gunicorn --bind 0.0…"   targeting-service    About a minute ago   Up About a minute             0.0.0.0:8003->8000/tcp, [::]:8003->8000/tcp

## Health checks

### auth-service / porta 8001 ###
{"status":"ok"}
OK: auth-service health

### flag-service / porta 8002 ###
{"status":"ok"}
OK: flag-service health

### targeting-service / porta 8003 ###
{"status":"ok"}
OK: targeting-service health

### evaluation-service / porta 8004 ###
{"status":"ok"}
OK: evaluation-service health

### analytics-service / porta 8005 ###
{"status":"ok"}
OK: analytics-service health
{"name":"phase2-e2e-local","key":"tm_key_REDACTED_RUNTIME_GENERATED","message":"Guarde esta chave com segurança! Você não poderá vê-la novamente."}
HTTP/1.1 200 OK
Date: Fri, 22 May 2026 16:29:21 GMT
Content-Length: 28
Content-Type: text/plain; charset=utf-8

{"message":"Chave válida"}
HTTP/1.1 409 CONFLICT
Server: gunicorn
Date: Fri, 22 May 2026 16:29:21 GMT
Connection: close
Content-Type: application/json
Content-Length: 55

{"error":"Flag 'enable-new-dashboard' j\u00e1 existe"}
HTTP/1.1 200 OK
Server: gunicorn
Date: Fri, 22 May 2026 16:29:21 GMT
Connection: close
Content-Type: application/json
Content-Length: 187

[{"created_at":"Fri, 22 May 2026 15:35:09 GMT","description":"Flag E2E local Fase 2","id":1,"is_enabled":true,"name":"enable-new-dashboard","updated_at":"Fri, 22 May 2026 15:35:09 GMT"}]
HTTP/1.1 409 CONFLICT
Server: gunicorn
Date: Fri, 22 May 2026 16:29:21 GMT
Connection: close
Content-Type: application/json
Content-Length: 68

{"error":"Regra para a flag 'enable-new-dashboard' j\u00e1 existe"}
HTTP/1.1 200 OK
Server: gunicorn
Date: Fri, 22 May 2026 16:29:21 GMT
Connection: close
Content-Type: application/json
Content-Length: 193

{"created_at":"Fri, 22 May 2026 15:38:27 GMT","flag_name":"enable-new-dashboard","id":1,"is_enabled":true,"rules":{"type":"PERCENTAGE","value":50},"updated_at":"Fri, 22 May 2026 15:38:27 GMT"}
HTTP/1.1 200 OK
Content-Type: application/json
Date: Fri, 22 May 2026 16:29:21 GMT
Content-Length: 72

{"flag_name":"enable-new-dashboard","user_id":"user-123","result":true}
HTTP/1.1 200 OK
Content-Type: application/json
Date: Fri, 22 May 2026 16:29:21 GMT
Content-Length: 73

{"flag_name":"enable-new-dashboard","user_id":"user-abc","result":false}
HTTP/1.1 200 OK
Content-Type: application/json
Date: Fri, 22 May 2026 16:29:21 GMT
Content-Length: 76

{"flag_name":"enable-new-dashboard","user_id":"user-123-sqs","result":true}
evaluation-service-1  | 2026/05/22 16:29:11 Conectado ao Redis com sucesso!
evaluation-service-1  | 2026/05/22 16:29:11 Usando endpoint AWS customizado: http://localstack:4566
evaluation-service-1  | 2026/05/22 16:29:11 Cliente SQS inicializado com sucesso.
evaluation-service-1  | 2026/05/22 16:29:11 Serviço de Avaliação (Go) rodando na porta 8000
evaluation-service-1  | 2026/05/22 16:29:21 Cache MISS para flag 'enable-new-dashboard'
evaluation-service-1  | 2026/05/22 16:29:21 Evento de avaliação enviado para SQS (Flag: enable-new-dashboard)
evaluation-service-1  | 2026/05/22 16:29:21 Cache HIT para flag 'enable-new-dashboard'
evaluation-service-1  | 2026/05/22 16:29:21 Evento de avaliação enviado para SQS (Flag: enable-new-dashboard)
evaluation-service-1  | 2026/05/22 16:29:21 Cache HIT para flag 'enable-new-dashboard'
evaluation-service-1  | 2026/05/22 16:29:21 Evento de avaliação enviado para SQS (Flag: enable-new-dashboard)
analytics-service-1  | [2026-05-22 16:27:58 +0000] [1] [INFO] Starting gunicorn 20.1.0
analytics-service-1  | [2026-05-22 16:27:58 +0000] [1] [INFO] Listening at: http://0.0.0.0:8000 (1)
analytics-service-1  | [2026-05-22 16:27:58 +0000] [1] [INFO] Using worker: sync
analytics-service-1  | [2026-05-22 16:27:58 +0000] [7] [INFO] Booting worker with pid: 7
analytics-service-1  | 2026-05-22 16:27:59,174 - INFO - Usando endpoint AWS customizado: http://localstack:4566
analytics-service-1  | 2026-05-22 16:27:59,179 - INFO - Found credentials in environment variables.
analytics-service-1  | 2026-05-22 16:27:59,263 - INFO - Clientes Boto3 inicializados na região us-east-1
analytics-service-1  | 2026-05-22 16:27:59,264 - INFO - Iniciando o worker SQS...
analytics-service-1  | 2026-05-22 16:29:21,305 - INFO - Recebidas 1 mensagens.
analytics-service-1  | 2026-05-22 16:29:21,305 - INFO - Processando mensagem ID: 0e4d02eb-c56e-4253-a177-b23185d201a7
analytics-service-1  | 2026-05-22 16:29:21,405 - INFO - Evento c45143ad-02f6-4bf3-9a7a-50e0ee06cd45 (Flag: enable-new-dashboard) salvo no DynamoDB.
analytics-service-1  | 2026-05-22 16:29:21,411 - INFO - Recebidas 2 mensagens.
analytics-service-1  | 2026-05-22 16:29:21,411 - INFO - Processando mensagem ID: ec7c5138-d102-413a-91f4-eedf0a92e87b
analytics-service-1  | 2026-05-22 16:29:21,418 - INFO - Evento a0213a3c-36a6-4577-9142-a2f20ff59425 (Flag: enable-new-dashboard) salvo no DynamoDB.
analytics-service-1  | 2026-05-22 16:29:21,419 - INFO - Processando mensagem ID: e39f1497-68a8-45ea-89bc-9a4bf9cbe2b3
analytics-service-1  | 2026-05-22 16:29:21,426 - INFO - Evento 2c07a9d5-0158-49d3-9934-ad97b606c9e7 (Flag: enable-new-dashboard) salvo no DynamoDB.
{
    "Items": [
        {
            "result": {
                "BOOL": true
            },
            "event_id": {
                "S": "2c07a9d5-0158-49d3-9934-ad97b606c9e7"
            },
            "user_id": {
                "S": "user-123-sqs"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-22T16:29:21.346570881Z"
            }
        },
        {
            "result": {
                "BOOL": true
            },
            "event_id": {
                "S": "c45143ad-02f6-4bf3-9a7a-50e0ee06cd45"
            },
            "user_id": {
                "S": "user-123"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-22T16:29:21.298592848Z"
            }
        },
        {
            "result": {
                "BOOL": false
            },
            "event_id": {
                "S": "a0213a3c-36a6-4577-9142-a2f20ff59425"
            },
            "user_id": {
                "S": "user-abc"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-22T16:29:21.318864199Z"
            }
        }
    ],
    "Count": 3,
    "ScannedCount": 3,
    "ConsumedCapacity": null
}

## Resultado final

BLOCO 17 validado com sucesso.

- Health dos 5 serviços: OK
- API key dinâmica: OK
- Flag: OK
- Targeting rule: OK
- Evaluation: OK
- Envio para SQS LocalStack: OK
- Consumo pelo analytics-service: OK
- Gravação DynamoDB LocalStack: OK
- DynamoDB Count: `3`

## Arquivos gerados

- Log: `/home/wellk/togglemaster-tc/fase2/logs/fase2-bloco17-e2e-flow.log`
- DynamoDB scan: `/home/wellk/togglemaster-tc/fase2/logs/fase2-bloco17-dynamodb-scan.json`
- Logs evaluation/SQS: `/home/wellk/togglemaster-tc/fase2/logs/fase2-bloco17-evaluation-sqs.log`
- Logs analytics: `/home/wellk/togglemaster-tc/fase2/logs/fase2-bloco17-analytics-consumo.log`
