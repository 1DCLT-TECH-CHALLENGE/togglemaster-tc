# Fase 2 - BLOCO 17.8 - Correção porta interna evaluation-service

Data: Fri May 22 12:19:37 PM -03 2026

## Objetivo
Padronizar o evaluation-service para escutar internamente na porta 8000, alinhado ao mapeamento host 8004 -> container 8000.
  evaluation-service:
    build:
      context: /home/wellk/togglemaster-tc/fase2/src/services/evaluation-service
      dockerfile: Dockerfile
    depends_on:
      flag-service:
        condition: service_started
        required: true
      localstack:
        condition: service_started
        required: true
      localstack-init:
        condition: service_started
        required: true
      redis:
        condition: service_started
        required: true
      targeting-service:
        condition: service_started
        required: true
    environment:
      AWS_ACCESS_KEY_ID: test
      AWS_ENDPOINT_URL: http://localstack:4566
      AWS_REGION: us-east-1
      AWS_SECRET_ACCESS_KEY: test
      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
      FLAG_SERVICE_URL: http://flag-service:8000
      PORT: "8000"
      REDIS_ADDR: redis:6379
      REDIS_HOST: redis
      REDIS_PORT: "6379"
      REDIS_URL: redis://redis:6379
      SERVICE_API_KEY: local-dev-api-key
      TARGETING_SERVICE_URL: http://targeting-service:8000
    networks:
      default: null
    ports:
      - mode: ingress
        target: 8000
        published: "8004"
        protocol: tcp
    restart: unless-stopped
NAME                          IMAGE                         COMMAND                  SERVICE              CREATED          STATUS                    PORTS
docker-analytics-service-1    docker-analytics-service      "gunicorn --bind 0.0…"   analytics-service    7 minutes ago    Up 7 minutes              0.0.0.0:8005->8000/tcp, [::]:8005->8000/tcp
docker-auth-service-1         docker-auth-service           "/app/service"           auth-service         2 minutes ago    Up 2 minutes              0.0.0.0:8001->8000/tcp, [::]:8001->8000/tcp
docker-evaluation-service-1   docker-evaluation-service     "/app/service"           evaluation-service   16 seconds ago   Up 15 seconds             0.0.0.0:8004->8000/tcp, [::]:8004->8000/tcp
docker-flag-service-1         docker-flag-service           "gunicorn --bind 0.0…"   flag-service         7 minutes ago    Up 7 minutes              0.0.0.0:8002->8000/tcp, [::]:8002->8000/tcp
docker-localstack-1           localstack/localstack:3.8.1   "docker-entrypoint.sh"   localstack           15 hours ago     Up 17 minutes (healthy)   4510-4559/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp, [::]:4566->4566/tcp
docker-localstack-init-1      amazon/aws-cli:2.15.7         "/bin/sh -c ' sleep …"   localstack-init      7 minutes ago    Up 15 seconds             
docker-postgres-auth-1        postgres:13                   "docker-entrypoint.s…"   postgres-auth        7 minutes ago    Up 7 minutes              0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp
docker-postgres-flags-1       postgres:13                   "docker-entrypoint.s…"   postgres-flags       7 minutes ago    Up 7 minutes              0.0.0.0:5434->5432/tcp, [::]:5434->5432/tcp
docker-postgres-targeting-1   postgres:13                   "docker-entrypoint.s…"   postgres-targeting   7 minutes ago    Up 7 minutes              0.0.0.0:5435->5432/tcp, [::]:5435->5432/tcp
docker-redis-1                redis:7-alpine                "docker-entrypoint.s…"   redis                7 minutes ago    Up 7 minutes              0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
docker-targeting-service-1    docker-targeting-service      "gunicorn --bind 0.0…"   targeting-service    7 minutes ago    Up 7 minutes              0.0.0.0:8003->8000/tcp, [::]:8003->8000/tcp
{"status":"ok"}

OK: evaluation-service respondeu health na porta 8004
evaluation-service-1  | 2026/05/22 15:19:38 Conectado ao Redis com sucesso!
evaluation-service-1  | 2026/05/22 15:19:38 Cliente SQS inicializado com sucesso.
evaluation-service-1  | 2026/05/22 15:19:38 Serviço de Avaliação (Go) rodando na porta 8000
