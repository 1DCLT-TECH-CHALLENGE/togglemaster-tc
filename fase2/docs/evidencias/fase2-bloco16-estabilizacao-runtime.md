# Fase 2 - BLOCO 16 - Estabilização Runtime

Data: Sat May 23 02:25:59 PM -03 2026

## Resultado

Runtime da Fase 2 estabilizado com sucesso.

## Containers

NAME                          IMAGE                         COMMAND                  SERVICE              CREATED          STATUS                    PORTS
docker-analytics-service-1    docker-analytics-service      "gunicorn --bind 0.0…"   analytics-service    23 seconds ago   Up 20 seconds             0.0.0.0:8005->8000/tcp, [::]:8005->8000/tcp
docker-auth-service-1         docker-auth-service           "/app/service"           auth-service         23 seconds ago   Up 21 seconds             0.0.0.0:8001->8000/tcp, [::]:8001->8000/tcp
docker-evaluation-service-1   docker-evaluation-service     "/app/service"           evaluation-service   22 seconds ago   Up 20 seconds             0.0.0.0:8004->8000/tcp, [::]:8004->8000/tcp
docker-flag-service-1         docker-flag-service           "gunicorn --bind 0.0…"   flag-service         23 seconds ago   Up 21 seconds             0.0.0.0:8002->8000/tcp, [::]:8002->8000/tcp
docker-localstack-1           localstack/localstack:3.8.1   "docker-entrypoint.sh"   localstack           25 hours ago     Up 15 minutes (healthy)   4510-4559/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp, [::]:4566->4566/tcp
docker-postgres-auth-1        postgres:13                   "docker-entrypoint.s…"   postgres-auth        25 hours ago     Up 15 minutes             0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp
docker-postgres-flags-1       postgres:13                   "docker-entrypoint.s…"   postgres-flags       25 hours ago     Up 15 minutes             0.0.0.0:5434->5432/tcp, [::]:5434->5432/tcp
docker-postgres-targeting-1   postgres:13                   "docker-entrypoint.s…"   postgres-targeting   25 hours ago     Up 15 minutes             0.0.0.0:5435->5432/tcp, [::]:5435->5432/tcp
docker-redis-1                redis:7-alpine                "docker-entrypoint.s…"   redis                25 hours ago     Up 15 minutes             0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
docker-targeting-service-1    docker-targeting-service      "gunicorn --bind 0.0…"   targeting-service    23 seconds ago   Up 21 seconds             0.0.0.0:8003->8000/tcp, [::]:8003->8000/tcp

## Health checks validados

- 8001 auth-service: OK
- 8002 flag-service: OK
- 8003 targeting-service: OK
- 8004 evaluation-service: OK
- 8005 analytics-service: OK

## Recursos LocalStack

- fila SQS: `togglemaster-events`
- tabela DynamoDB: `ToggleMasterAnalytics`

## Arquivos

- Log: `/home/wellk/togglemaster-tc/fase2/logs/fase2-bloco16-stabilize-runtime.log`
- SQS list queues: `/home/wellk/togglemaster-tc/fase2/logs/fase2-bloco16-sqs-list-queues.json`
- DynamoDB list tables: `/home/wellk/togglemaster-tc/fase2/logs/fase2-bloco16-dynamodb-list-tables.json`
