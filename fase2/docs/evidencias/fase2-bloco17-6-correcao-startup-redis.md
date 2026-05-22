# Fase 2 - BLOCO 17.6 - Correção startup race + Redis env

Data: Fri May 22 12:16:02 PM -03 2026

## Objetivo
Corrigir a corrida de inicialização do auth-service com PostgreSQL e o endereço Redis do evaluation-service.

/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/README.md:5:Ele é otimizado para alta velocidade e baixa latência usando **cache em Redis**.
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/README.md:9:2.  Busca as regras da flag no **Redis**.
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/README.md:13:    * Salva o resultado no Redis com um TTL (Time-To-Live) curto.
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/README.md:21:* [Redis](https://redis.io/docs/getting-started/installation/) (rodando localmente ou em Docker)
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/README.md:45:    # URL do seu Redis local
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/README.md:46:    REDIS_URL="redis://localhost:6379"
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/go.sum:12:github.com/go-redis/redis/v8 v8.11.5 h1:AcZZR7igkdvfVmQTPnu9WE37LRrO/YrBH5zWyjDC0oI=
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/go.sum:13:github.com/go-redis/redis/v8 v8.11.5/go.mod h1:gREzHqY1hg6oD9ngVRbLStwAWKhA0FEgq8Jd4h5lpwo=
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:13:	"github.com/go-redis/redis/v8"
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:17:// Contexto global para o Redis
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:22:	RedisClient         *redis.Client
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:34:	port := os.Getenv("PORT")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:39:	redisURL := os.Getenv("REDIS_URL")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:40:	if redisURL == "" {
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:41:		log.Fatal("REDIS_URL deve ser definida (ex: redis://localhost:6379)")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:44:	flagSvcURL := os.Getenv("FLAG_SERVICE_URL")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:49:	targetingSvcURL := os.Getenv("TARGETING_SERVICE_URL")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:55:	sqsQueueURL := os.Getenv("AWS_SQS_URL")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:56:	awsRegion := os.Getenv("AWS_REGION")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:66:	// Cliente Redis
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:67:	opt, err := redis.ParseURL(redisURL)
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:69:		log.Fatalf("Não foi possível parsear a URL do Redis: %v", err)
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:71:	rdb := redis.NewClient(opt)
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:73:		log.Fatalf("Não foi possível conectar ao Redis: %v", err)
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:75:	log.Println("Conectado ao Redis com sucesso!")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/main.go:95:		RedisClient:         rdb,
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/go.mod:7:	github.com/go-redis/redis/v8 v8.11.5
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/evaluator.go:33:// getCombinedFlagInfo busca os dados no Redis, com fallback para os microsserviços
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/evaluator.go:37:	// 1. Tentar buscar do Cache (Redis)
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/evaluator.go:38:	val, err := a.RedisClient.Get(ctx, cacheKey).Result()
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/evaluator.go:60:		a.RedisClient.Set(ctx, cacheKey, jsonData, CACHE_TTL).Err()
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/evaluator.go:106:	apiKey := os.Getenv("SERVICE_API_KEY")
/home/wellk/togglemaster-tc/fase2/src/services/evaluation-service/evaluator.go:133:	apiKey := os.Getenv("SERVICE_API_KEY") // Usa a mesma chave
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
      REDIS_ADDR: redis:6379
      REDIS_HOST: redis
      REDIS_PORT: "6379"
      REDIS_URL: redis:6379
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
  auth-service:
    build:
      context: /home/wellk/togglemaster-tc/fase2/src/services/auth-service
      dockerfile: Dockerfile
    depends_on:
      postgres-auth:
        condition: service_started
        required: true
    environment:
      DATABASE_URL: postgres://auth_user:auth_pass@postgres-auth:5432/auth_db?sslmode=disable
      MASTER_KEY: local-master-key
      PORT: "8001"
    networks:
      default: null
    ports:
      - mode: ingress
        target: 8000
        published: "8001"
        protocol: tcp
    restart: unless-stopped
NAME                          IMAGE                         COMMAND                  SERVICE              CREATED          STATUS                         PORTS
docker-analytics-service-1    docker-analytics-service      "gunicorn --bind 0.0…"   analytics-service    4 minutes ago    Up 4 minutes                   0.0.0.0:8005->8000/tcp, [::]:8005->8000/tcp
docker-auth-service-1         docker-auth-service           "/app/service"           auth-service         20 seconds ago   Up 20 seconds                  0.0.0.0:8001->8000/tcp, [::]:8001->8000/tcp
docker-evaluation-service-1   docker-evaluation-service     "/app/service"           evaluation-service   20 seconds ago   Restarting (1) 4 seconds ago   
docker-flag-service-1         docker-flag-service           "gunicorn --bind 0.0…"   flag-service         4 minutes ago    Up 4 minutes                   0.0.0.0:8002->8000/tcp, [::]:8002->8000/tcp
docker-localstack-1           localstack/localstack:3.8.1   "docker-entrypoint.sh"   localstack           15 hours ago     Up 13 minutes (healthy)        4510-4559/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp, [::]:4566->4566/tcp
docker-localstack-init-1      amazon/aws-cli:2.15.7         "/bin/sh -c ' sleep …"   localstack-init      4 minutes ago    Exited (0) 3 seconds ago       
docker-postgres-auth-1        postgres:13                   "docker-entrypoint.s…"   postgres-auth        4 minutes ago    Up 4 minutes                   0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp
docker-postgres-flags-1       postgres:13                   "docker-entrypoint.s…"   postgres-flags       4 minutes ago    Up 4 minutes                   0.0.0.0:5434->5432/tcp, [::]:5434->5432/tcp
docker-postgres-targeting-1   postgres:13                   "docker-entrypoint.s…"   postgres-targeting   4 minutes ago    Up 4 minutes                   0.0.0.0:5435->5432/tcp, [::]:5435->5432/tcp
docker-redis-1                redis:7-alpine                "docker-entrypoint.s…"   redis                4 minutes ago    Up 4 minutes                   0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
docker-targeting-service-1    docker-targeting-service      "gunicorn --bind 0.0…"   targeting-service    4 minutes ago    Up 4 minutes                   0.0.0.0:8003->8000/tcp, [::]:8003->8000/tcp

### PORTA 8001 ###

### PORTA 8004 ###
auth-service-1  | 2026/05/22 15:16:03 Conectado ao PostgreSQL com sucesso!
auth-service-1  | 2026/05/22 15:16:03 Serviço de Autenticação (Go) rodando na porta 8001
evaluation-service-1  | 2026/05/22 15:16:04 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
evaluation-service-1  | 2026/05/22 15:16:04 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
evaluation-service-1  | 2026/05/22 15:16:05 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
evaluation-service-1  | 2026/05/22 15:16:05 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
evaluation-service-1  | 2026/05/22 15:16:07 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
evaluation-service-1  | 2026/05/22 15:16:09 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
evaluation-service-1  | 2026/05/22 15:16:12 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
evaluation-service-1  | 2026/05/22 15:16:19 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
