# FASE 2 - BLOCO 8 - CONTRATOS DOS SERVIÇOS

Data: Tue May 19 03:28:10 PM -03 2026


============================================================
SERVIÇO: auth-service
============================================================

## PORTAS / LISTEN
./key.go:3:import (
./.git/hooks/post-update.sample:4:# dumb transports.
./.git/hooks/pre-commit.sample:29:	# even required, for portability to Solaris 10's /usr/bin/tr), since
./.git/hooks/pre-commit.sample:39:To be portable it is advisable to rename the file.
./.git/hooks/fsmonitor-watchman.sample:26:	die "Unsupported query-fsmonitor hook version '$version'.\n" .
./.git/hooks/pre-rebase.sample:124:    Then you can delete it.  More importantly, you should not
./README.md:25:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/auth_db"
./README.md:27:    # Porta que o serviço irá rodar
./README.md:28:    PORT="8001"
./README.md:43:    O servidor estará rodando em `http://localhost:8001`.
./README.md:51:curl http://localhost:8001/health
./README.md:59:curl -X POST http://localhost:8001/admin/keys \
./README.md:78:curl http://localhost:8001/validate \
./README.md:87:curl http://localhost:8001/validate \
./main.go:3:import (
./main.go:25:	port := os.Getenv("PORT")
./main.go:26:	if port == "" {
./main.go:27:		port = "8001" // Porta padrão
./main.go:63:	log.Printf("Serviço de Autenticação (Go) rodando na porta %s", port)
./main.go:64:	if err := http.ListenAndServe(":"+port, mux); err != nil {
./handlers.go:3:import (

## VARIÁVEIS DE AMBIENTE
./README.md:16:    * Execute o script `db/init.sql` para criar a tabela `api_keys`:
./README.md:25:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/auth_db"
./README.md:31:    MASTER_KEY="admin-secreto-123"
./README.md:56:**2. Crie uma nova Chave de API (requer a MASTER_KEY):**
./db/init.sql:1:CREATE TABLE IF NOT EXISTS api_keys (
./main.go:25:	port := os.Getenv("PORT")
./main.go:30:	databaseURL := os.Getenv("DATABASE_URL")
./main.go:32:		log.Fatal("DATABASE_URL deve ser definida")
./main.go:35:	masterKey := os.Getenv("MASTER_KEY")
./main.go:37:		log.Fatal("MASTER_KEY deve ser definida")
./handlers.go:46:	err := a.DB.QueryRow("SELECT id FROM api_keys WHERE key_hash = $1 AND is_active = true", keyHash).Scan(&id)
./handlers.go:88:		"INSERT INTO api_keys (name, key_hash) VALUES ($1, $2) RETURNING id",
./handlers.go:109:// masterKeyAuthMiddleware protege endpoints que só podem ser acessados com a MASTER_KEY

## ENDPOINTS HTTP
./main.go:54:	mux.HandleFunc("/health", app.healthHandler)
./main.go:57:	mux.HandleFunc("/validate", app.validateKeyHandler)
./main.go:61:	mux.Handle("/admin/keys", app.masterKeyAuthMiddleware(http.HandlerFunc(app.createKeyHandler)))

## CHAMADAS HTTP
./.git/config:7:	url = https://github.com/FIAP-TCs/auth-service.git
./.git/logs/refs/heads/main:1:0000000000000000000000000000000000000000 56e447f83409bf35b22ef04a9e39c2e30df9af33 wellk <wellk@tc-fiap.(none)> 1779210386 -0300	clone: from https://github.com/FIAP-TCs/auth-service.git
./.git/logs/refs/remotes/origin/HEAD:1:0000000000000000000000000000000000000000 56e447f83409bf35b22ef04a9e39c2e30df9af33 wellk <wellk@tc-fiap.(none)> 1779210386 -0300	clone: from https://github.com/FIAP-TCs/auth-service.git
./.git/logs/HEAD:1:0000000000000000000000000000000000000000 56e447f83409bf35b22ef04a9e39c2e30df9af33 wellk <wellk@tc-fiap.(none)> 1779210386 -0300	clone: from https://github.com/FIAP-TCs/auth-service.git
./.git/hooks/fsmonitor-watchman.sample:8:# (https://facebook.github.io/watchman/) with git to speed up detecting
./README.md:7:* [Go](https://go.dev/doc/install) (versão 1.21 ou superior)
./README.md:8:* [PostgreSQL](https://www.postgresql.org/download/) (rodando localmente ou em um contêiner Docker)
./README.md:43:    O servidor estará rodando em `http://localhost:8001`.
./README.md:51:curl http://localhost:8001/health
./README.md:59:curl -X POST http://localhost:8001/admin/keys \
./README.md:78:curl http://localhost:8001/validate \
./README.md:87:curl http://localhost:8001/validate \

## POSTGRES / REDIS
./README.md:8:* [PostgreSQL](https://www.postgresql.org/download/) (rodando localmente ou em um contêiner Docker)
./README.md:15:    * Crie um banco de dados no seu PostgreSQL (ex: `auth_db`).
./README.md:24:    # String de conexão do seu banco de dados PostgreSQL
./README.md:25:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/auth_db"
./main.go:10:	"github.com/jackc/pgx/v4/stdlib"
./main.go:69:// connectDB inicializa e testa a conexão com o PostgreSQL
./main.go:71:	db, err := sql.Open("pgx", databaseURL)
./main.go:80:	log.Println("Conectado ao PostgreSQL com sucesso!")
./go.mod:6:	github.com/jackc/pgx/v4 v4.18.3
./go.mod:18:	github.com/jackc/pgx/v4/stdlib v4.18.3 // indirect

## AWS / SQS / DYNAMODB


============================================================
SERVIÇO: flag-service
============================================================

## PORTAS / LISTEN
./.git/hooks/post-update.sample:4:# dumb transports.
./.git/hooks/pre-commit.sample:29:	# even required, for portability to Solaris 10's /usr/bin/tr), since
./.git/hooks/pre-commit.sample:39:To be portable it is advisable to rename the file.
./.git/hooks/fsmonitor-watchman.sample:26:	die "Unsupported query-fsmonitor hook version '$version'.\n" .
./.git/hooks/pre-rebase.sample:124:    Then you can delete it.  More importantly, you should not
./README.md:5:**IMPORTANTE:** Este serviço é protegido e depende que o `auth-service` esteja rodando. Todas as requisições (exceto `/health`) exigem um header `Authorization: Bearer <sua-chave-api>`.
./README.md:11:* O `auth-service` deve estar rodando (localmente na porta `8001`).
./README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/flags_db"
./README.md:30:    # Porta que este serviço (flag-service) irá rodar
./README.md:31:    PORT="8002"
./README.md:33:    # URL do auth-service (que deve estar rodando na porta 8001)
./README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
./README.md:44:    gunicorn --bind 0.0.0.0:8002 app:app
./README.md:46:    O servidor estará rodando em `http://localhost:8002`.
./README.md:54:    curl -X POST http://localhost:8001/admin/keys \
./README.md:67:curl http://localhost:8002/health
./README.md:74:curl http://localhost:8002/flags
./README.md:81:curl -X POST http://localhost:8002/flags \
./README.md:94:curl http://localhost:8002/flags \
./README.md:101:curl -X PUT http://localhost:8002/flags/enable-new-dashboard \
./app.py:1:import os
./app.py:2:import sys
./app.py:3:import psycopg2
./app.py:4:import requests
./app.py:5:from psycopg2.extras import RealDictCursor
./app.py:6:from psycopg2.pool import SimpleConnectionPool
./app.py:7:from flask import Flask, request, jsonify
./app.py:8:from dotenv import load_dotenv
./app.py:9:from functools import wraps
./app.py:10:import logging
./app.py:225:    port = int(os.getenv("PORT", 8002))
./app.py:226:    app.run(host='0.0.0.0', port=port, debug=False)
./requirements.txt:3:gunicorn==20.1.0
./Dockerfile:13:    && pip install --no-cache-dir gunicorn
./Dockerfile:19:CMD ["gunicorn", "--bind", "0.0.0.0:8002", "app:app"]

## VARIÁVEIS DE AMBIENTE
./README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/flags_db"
./README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
./app.py:22:DATABASE_URL = os.getenv("DATABASE_URL")
./app.py:23:AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL")
./app.py:25:if not DATABASE_URL or not AUTH_SERVICE_URL:
./app.py:26:    log.critical("Erro: DATABASE_URL e AUTH_SERVICE_URL devem ser definidos.")
./app.py:32:    pool = SimpleConnectionPool(1, 5, dsn=DATABASE_URL)
./app.py:49:            validate_url = f"{AUTH_SERVICE_URL}/validate"
./app.py:225:    port = int(os.getenv("PORT", 8002))

## ENDPOINTS HTTP

## CHAMADAS HTTP
./.git/config:7:	url = https://github.com/FIAP-TCs/flag-service.git
./.git/logs/refs/heads/main:1:0000000000000000000000000000000000000000 21052b1abcf209ea6848350bdd9928b80b7f86fe wellk <wellk@tc-fiap.(none)> 1779210387 -0300	clone: from https://github.com/FIAP-TCs/flag-service.git
./.git/logs/refs/remotes/origin/HEAD:1:0000000000000000000000000000000000000000 21052b1abcf209ea6848350bdd9928b80b7f86fe wellk <wellk@tc-fiap.(none)> 1779210387 -0300	clone: from https://github.com/FIAP-TCs/flag-service.git
./.git/logs/HEAD:1:0000000000000000000000000000000000000000 21052b1abcf209ea6848350bdd9928b80b7f86fe wellk <wellk@tc-fiap.(none)> 1779210387 -0300	clone: from https://github.com/FIAP-TCs/flag-service.git
./.git/hooks/fsmonitor-watchman.sample:8:# (https://facebook.github.io/watchman/) with git to speed up detecting
./README.md:9:* [Python](https://www.python.org/) (versão 3.9 ou superior)
./README.md:10:* [PostgreSQL](https://www.postgresql.org/download/) (rodando localmente ou em um contêiner Docker)
./README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
./README.md:46:    O servidor estará rodando em `http://localhost:8002`.
./README.md:54:    curl -X POST http://localhost:8001/admin/keys \
./README.md:67:curl http://localhost:8002/health
./README.md:74:curl http://localhost:8002/flags
./README.md:81:curl -X POST http://localhost:8002/flags \
./README.md:94:curl http://localhost:8002/flags \
./README.md:101:curl -X PUT http://localhost:8002/flags/enable-new-dashboard \
./app.py:50:            response = requests.get(validate_url, headers={"Authorization": auth_header}, timeout=3)
./app.py:56:        except requests.exceptions.Timeout:
./app.py:59:        except requests.exceptions.RequestException as e:

## POSTGRES / REDIS
./README.md:10:* [PostgreSQL](https://www.postgresql.org/download/) (rodando localmente ou em um contêiner Docker)
./README.md:18:    * Crie um banco de dados no seu PostgreSQL (ex: `flags_db`).
./README.md:27:    # String de conexão do seu banco de dados PostgreSQL
./README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/flags_db"
./app.py:3:import psycopg2
./app.py:5:from psycopg2.extras import RealDictCursor
./app.py:6:from psycopg2.pool import SimpleConnectionPool
./app.py:33:    log.info("Pool de conexões com o PostgreSQL inicializado.")
./app.py:34:except psycopg2.OperationalError as e:
./app.py:35:    log.critical(f"Erro fatal ao conectar ao PostgreSQL: {e}")
./app.py:99:    except psycopg2.IntegrityError:
./requirements.txt:2:psycopg2-binary==2.9.5

## AWS / SQS / DYNAMODB


============================================================
SERVIÇO: targeting-service
============================================================

## PORTAS / LISTEN
./.git/hooks/post-update.sample:4:# dumb transports.
./.git/hooks/pre-commit.sample:29:	# even required, for portability to Solaris 10's /usr/bin/tr), since
./.git/hooks/pre-commit.sample:39:To be portable it is advisable to rename the file.
./.git/hooks/fsmonitor-watchman.sample:26:	die "Unsupported query-fsmonitor hook version '$version'.\n" .
./.git/hooks/pre-rebase.sample:124:    Then you can delete it.  More importantly, you should not
./README.md:5:**IMPORTANTE:** Este serviço também é protegido e depende que o `auth-service` esteja rodando (ex: em `http://localhost:8001`).
./README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/targeting_db"
./README.md:30:    # Porta que este serviço (targeting-service) irá rodar
./README.md:31:    PORT="8003"
./README.md:33:    # URL do auth-service (que deve estar rodando na porta 8001)
./README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
./README.md:44:    gunicorn --bind 0.0.0.0:8003 app:app
./README.md:46:    O servidor estará rodando em `http://localhost:8003`.
./README.md:54:curl http://localhost:8003/health
./README.md:60:curl -X POST http://localhost:8003/rules \
./README.md:76:curl http://localhost:8003/rules/enable-new-dashboard \
./README.md:83:curl -X PUT http://localhost:8003/rules/enable-new-dashboard \
./app.py:1:import os
./app.py:2:import sys
./app.py:3:import psycopg2
./app.py:4:import requests
./app.py:5:import json
./app.py:6:from psycopg2.extras import RealDictCursor, Json
./app.py:7:from psycopg2.pool import SimpleConnectionPool
./app.py:8:from flask import Flask, request, jsonify
./app.py:9:from dotenv import load_dotenv
./app.py:10:from functools import wraps
./app.py:11:import logging
./app.py:203:    port = int(os.getenv("PORT", 8003))
./app.py:204:    app.run(host='0.0.0.0', port=port, debug=False)
./requirements.txt:3:gunicorn==20.1.0
./Dockerfile:13:    && pip install --no-cache-dir gunicorn
./Dockerfile:19:CMD ["gunicorn", "--bind", "0.0.0.0:8003", "app:app"]

## VARIÁVEIS DE AMBIENTE
./README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/targeting_db"
./README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
./app.py:23:DATABASE_URL = os.getenv("DATABASE_URL")
./app.py:24:AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL")
./app.py:26:if not DATABASE_URL or not AUTH_SERVICE_URL:
./app.py:27:    log.critical("Erro: DATABASE_URL e AUTH_SERVICE_URL devem ser definidos.")
./app.py:32:    pool = SimpleConnectionPool(1, 5, dsn=DATABASE_URL)
./app.py:48:            validate_url = f"{AUTH_SERVICE_URL}/validate"
./app.py:203:    port = int(os.getenv("PORT", 8003))

## ENDPOINTS HTTP

## CHAMADAS HTTP
./.git/config:7:	url = https://github.com/FIAP-TCs/targeting-service.git
./.git/logs/refs/heads/main:1:0000000000000000000000000000000000000000 dd9568a583fa409b88a446685779d9e581282fd2 wellk <wellk@tc-fiap.(none)> 1779210387 -0300	clone: from https://github.com/FIAP-TCs/targeting-service.git
./.git/logs/refs/remotes/origin/HEAD:1:0000000000000000000000000000000000000000 dd9568a583fa409b88a446685779d9e581282fd2 wellk <wellk@tc-fiap.(none)> 1779210387 -0300	clone: from https://github.com/FIAP-TCs/targeting-service.git
./.git/logs/HEAD:1:0000000000000000000000000000000000000000 dd9568a583fa409b88a446685779d9e581282fd2 wellk <wellk@tc-fiap.(none)> 1779210387 -0300	clone: from https://github.com/FIAP-TCs/targeting-service.git
./.git/hooks/fsmonitor-watchman.sample:8:# (https://facebook.github.io/watchman/) with git to speed up detecting
./README.md:5:**IMPORTANTE:** Este serviço também é protegido e depende que o `auth-service` esteja rodando (ex: em `http://localhost:8001`).
./README.md:9:* [Python](https://www.python.org/) (versão 3.9 ou superior)
./README.md:10:* [PostgreSQL](https://www.postgresql.org/download/)
./README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
./README.md:46:    O servidor estará rodando em `http://localhost:8003`.
./README.md:54:curl http://localhost:8003/health
./README.md:60:curl -X POST http://localhost:8003/rules \
./README.md:76:curl http://localhost:8003/rules/enable-new-dashboard \
./README.md:83:curl -X PUT http://localhost:8003/rules/enable-new-dashboard \
./app.py:49:            response = requests.get(validate_url, headers={"Authorization": auth_header}, timeout=3)
./app.py:55:        except requests.exceptions.Timeout:
./app.py:58:        except requests.exceptions.RequestException as e:

## POSTGRES / REDIS
./README.md:10:* [PostgreSQL](https://www.postgresql.org/download/)
./README.md:18:    * Crie um banco de dados no seu PostgreSQL (ex: `targeting_db`).
./README.md:27:    # String de conexão do seu banco de dados PostgreSQL
./README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/targeting_db"
./app.py:3:import psycopg2
./app.py:6:from psycopg2.extras import RealDictCursor, Json
./app.py:7:from psycopg2.pool import SimpleConnectionPool
./app.py:33:    log.info("Pool de conexões com o PostgreSQL (targeting) inicializado.")
./app.py:34:except psycopg2.OperationalError as e:
./app.py:35:    log.critical(f"Erro fatal ao conectar ao PostgreSQL: {e}")
./app.py:97:    except psycopg2.IntegrityError:
./requirements.txt:2:psycopg2-binary==2.9.5

## AWS / SQS / DYNAMODB


============================================================
SERVIÇO: evaluation-service
============================================================

## PORTAS / LISTEN
./.git/hooks/post-update.sample:4:# dumb transports.
./.git/hooks/pre-commit.sample:29:	# even required, for portability to Solaris 10's /usr/bin/tr), since
./.git/hooks/pre-commit.sample:39:To be portable it is advisable to rename the file.
./.git/hooks/fsmonitor-watchman.sample:26:	die "Unsupported query-fsmonitor hook version '$version'.\n" .
./.git/hooks/pre-rebase.sample:124:    Then you can delete it.  More importantly, you should not
./README.md:32:    curl -X POST http://localhost:8001/admin/keys \
./README.md:42:    # Porta que este serviço irá rodar
./README.md:43:    PORT="8004"
./README.md:46:    REDIS_URL="redis://localhost:6379"
./README.md:49:    FLAG_SERVICE_URL="http://localhost:8002"
./README.md:50:    TARGETING_SERVICE_URL="http://localhost:8003"
./README.md:72:    O servidor estará rodando em `http://localhost:8004`.
./README.md:82:curl http://localhost:8004/health
./README.md:90:curl "http://localhost:8004/evaluate?user_id=user-123&flag_name=enable-new-dashboard"
./README.md:96:curl "http://localhost:8004/evaluate?user_id=user-abc&flag_name=enable-new-dashboard"
./sqs.go:3:import (
./main.go:3:import (
./main.go:34:	port := os.Getenv("PORT")
./main.go:35:	if port == "" {
./main.go:36:		port = "8004"
./main.go:41:		log.Fatal("REDIS_URL deve ser definida (ex: redis://localhost:6379)")
./main.go:108:	log.Printf("Serviço de Avaliação (Go) rodando na porta %s", port)
./main.go:109:	if err := http.ListenAndServe(":"+port, mux); err != nil {
./handlers.go:3:import (
./handlers.go:36:		// Se o erro for "não encontrado", retornamos 'false' (comportamento seguro)
./evaluator.go:3:import (
./types.go:3:import "fmt"

## VARIÁVEIS DE AMBIENTE
./README.md:5:Ele é otimizado para alta velocidade e baixa latência usando **cache em Redis**.
./README.md:9:2.  Busca as regras da flag no **Redis**.
./README.md:13:    * Salva o resultado no Redis com um TTL (Time-To-Live) curto.
./README.md:16:6.  Envia *assincronamente* um evento da decisão para uma fila **AWS SQS**.
./README.md:21:* [Redis](https://redis.io/docs/getting-started/installation/) (rodando localmente ou em Docker)
./README.md:23:* **Credenciais da AWS:** Para o SQS funcionar, seu terminal deve estar autenticado na AWS (ex: via `aws configure` ou variáveis de ambiente).
./README.md:30:    Este serviço precisa se autenticar no `flag-service` e no `targeting-service`. Você deve criar uma chave de API para ele usando o `auth-service` (com a `MASTER_KEY`).
./README.md:45:    # URL do seu Redis local
./README.md:46:    REDIS_URL="redis://localhost:6379"
./README.md:49:    FLAG_SERVICE_URL="http://localhost:8002"
./README.md:50:    TARGETING_SERVICE_URL="http://localhost:8003"
./README.md:53:    SERVICE_API_KEY="SUA_CHAVE_DE_SERVICO"
./README.md:56:    # Cole a URL da fila SQS que você criou no console da AWS
./README.md:57:    AWS_SQS_URL="[https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
./README.md:59:    # Região da sua fila SQS
./README.md:60:    AWS_REGION="us-east-1" 
./README.md:102:**4. Verifique a Fila SQS:** Após fazer as chamadas acima, vá até o console da AWS, abra sua fila SQS e verifique se as mensagens (`EvaluationEvent`) estão chegando.
./sqs.go:9:	"github.com/aws/aws-sdk-go/service/sqs"
./sqs.go:20:// sendEvaluationEvent envia um evento para a fila SQS
./sqs.go:23:	if a.SqsSvc == nil || a.SqsQueueURL == "" {
./sqs.go:24:		log.Printf("[SQS_DISABLED] Evento: User '%s', Flag '%s', Result '%t'", userID, flagName, result)
./sqs.go:37:		log.Printf("Erro ao serializar evento SQS: %v", err)
./sqs.go:42:	_, err = a.SqsSvc.SendMessage(&sqs.SendMessageInput{
./sqs.go:44:		QueueUrl:    aws.String(a.SqsQueueURL),
./sqs.go:48:		log.Printf("Erro ao enviar mensagem para SQS: %v", err)
./sqs.go:50:		log.Printf("Evento de avaliação enviado para SQS (Flag: %s)", flagName)
./go.sum:7:	github.com/go-redis/redis/v8 v8.11.5
./main.go:12:	"github.com/aws/aws-sdk-go/service/sqs"
./main.go:13:	"github.com/go-redis/redis/v8"
./main.go:17:// Contexto global para o Redis
./main.go:22:	RedisClient         *redis.Client
./main.go:23:	SqsSvc              *sqs.SQS
./main.go:24:	SqsQueueURL         string
./main.go:34:	port := os.Getenv("PORT")
./main.go:39:	redisURL := os.Getenv("REDIS_URL")
./main.go:40:	if redisURL == "" {
./main.go:41:		log.Fatal("REDIS_URL deve ser definida (ex: redis://localhost:6379)")
./main.go:44:	flagSvcURL := os.Getenv("FLAG_SERVICE_URL")
./main.go:46:		log.Fatal("FLAG_SERVICE_URL deve ser definida")
./main.go:49:	targetingSvcURL := os.Getenv("TARGETING_SERVICE_URL")
./main.go:51:		log.Fatal("TARGETING_SERVICE_URL deve ser definida")
./main.go:54:	// SQS é opcional no dev local, mas obrigatório em prod
./main.go:55:	sqsQueueURL := os.Getenv("AWS_SQS_URL")
./main.go:56:	awsRegion := os.Getenv("AWS_REGION")
./main.go:57:	if sqsQueueURL == "" {
./main.go:58:		log.Println("Atenção: AWS_SQS_URL não definida. Eventos não serão enviados.")
./main.go:60:	if awsRegion == "" && sqsQueueURL != "" {
./main.go:61:		log.Fatal("AWS_REGION deve ser definida para usar SQS")
./main.go:66:	// Cliente Redis
./main.go:67:	opt, err := redis.ParseURL(redisURL)
./main.go:69:		log.Fatalf("Não foi possível parsear a URL do Redis: %v", err)
./main.go:71:	rdb := redis.NewClient(opt)
./main.go:73:		log.Fatalf("Não foi possível conectar ao Redis: %v", err)
./main.go:75:	log.Println("Conectado ao Redis com sucesso!")
./main.go:77:	// Cliente SQS (AWS SDK)
./main.go:78:	var sqsSvc *sqs.SQS
./main.go:79:	if sqsQueueURL != "" {
./main.go:84:		sqsSvc = sqs.New(sess)
./main.go:85:		log.Println("Cliente SQS inicializado com sucesso.")
./main.go:95:		RedisClient:         rdb,
./main.go:96:		SqsSvc:              sqsSvc,
./main.go:97:		SqsQueueURL:         sqsQueueURL,
./handlers.go:47:	// 3. Enviar evento para SQS (assincronamente)
./go.mod:7:	github.com/go-redis/redis/v8 v8.11.5
./evaluator.go:33:// getCombinedFlagInfo busca os dados no Redis, com fallback para os microsserviços
./evaluator.go:37:	// 1. Tentar buscar do Cache (Redis)
./evaluator.go:38:	val, err := a.RedisClient.Get(ctx, cacheKey).Result()
./evaluator.go:60:		a.RedisClient.Set(ctx, cacheKey, jsonData, CACHE_TTL).Err()
./evaluator.go:106:	apiKey := os.Getenv("SERVICE_API_KEY")
./evaluator.go:133:	apiKey := os.Getenv("SERVICE_API_KEY") // Usa a mesma chave

## ENDPOINTS HTTP
./main.go:105:	mux.HandleFunc("/health", app.healthHandler)
./main.go:106:	mux.HandleFunc("/evaluate", app.evaluationHandler)

## CHAMADAS HTTP
./.git/config:7:	url = https://github.com/FIAP-TCs/evaluation-service.git
./.git/logs/refs/heads/main:1:0000000000000000000000000000000000000000 5e8ade059f69650d2e8cfbefad0a83cfac25f0a9 wellk <wellk@tc-fiap.(none)> 1779210388 -0300	clone: from https://github.com/FIAP-TCs/evaluation-service.git
./.git/logs/refs/remotes/origin/HEAD:1:0000000000000000000000000000000000000000 5e8ade059f69650d2e8cfbefad0a83cfac25f0a9 wellk <wellk@tc-fiap.(none)> 1779210388 -0300	clone: from https://github.com/FIAP-TCs/evaluation-service.git
./.git/logs/HEAD:1:0000000000000000000000000000000000000000 5e8ade059f69650d2e8cfbefad0a83cfac25f0a9 wellk <wellk@tc-fiap.(none)> 1779210388 -0300	clone: from https://github.com/FIAP-TCs/evaluation-service.git
./.git/hooks/fsmonitor-watchman.sample:8:# (https://facebook.github.io/watchman/) with git to speed up detecting
./README.md:20:* [Go](https://go.dev/doc/install) (versão 1.21 ou superior)
./README.md:21:* [Redis](https://redis.io/docs/getting-started/installation/) (rodando localmente ou em Docker)
./README.md:32:    curl -X POST http://localhost:8001/admin/keys \
./README.md:49:    FLAG_SERVICE_URL="http://localhost:8002"
./README.md:50:    TARGETING_SERVICE_URL="http://localhost:8003"
./README.md:57:    AWS_SQS_URL="[https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
./README.md:72:    O servidor estará rodando em `http://localhost:8004`.
./README.md:82:curl http://localhost:8004/health
./README.md:90:curl "http://localhost:8004/evaluate?user_id=user-123&flag_name=enable-new-dashboard"
./README.md:96:curl "http://localhost:8004/evaluate?user_id=user-abc&flag_name=enable-new-dashboard"
./evaluator.go:110:	resp, err := a.HttpClient.Do(req)
./evaluator.go:137:	resp, err := a.HttpClient.Do(req)

## POSTGRES / REDIS
./README.md:5:Ele é otimizado para alta velocidade e baixa latência usando **cache em Redis**.
./README.md:9:2.  Busca as regras da flag no **Redis**.
./README.md:13:    * Salva o resultado no Redis com um TTL (Time-To-Live) curto.
./README.md:21:* [Redis](https://redis.io/docs/getting-started/installation/) (rodando localmente ou em Docker)
./README.md:45:    # URL do seu Redis local
./README.md:46:    REDIS_URL="redis://localhost:6379"
./go.sum:7:	github.com/go-redis/redis/v8 v8.11.5
./main.go:13:	"github.com/go-redis/redis/v8"
./main.go:17:// Contexto global para o Redis
./main.go:22:	RedisClient         *redis.Client
./main.go:39:	redisURL := os.Getenv("REDIS_URL")
./main.go:40:	if redisURL == "" {
./main.go:41:		log.Fatal("REDIS_URL deve ser definida (ex: redis://localhost:6379)")
./main.go:66:	// Cliente Redis
./main.go:67:	opt, err := redis.ParseURL(redisURL)
./main.go:69:		log.Fatalf("Não foi possível parsear a URL do Redis: %v", err)
./main.go:71:	rdb := redis.NewClient(opt)
./main.go:73:		log.Fatalf("Não foi possível conectar ao Redis: %v", err)
./main.go:75:	log.Println("Conectado ao Redis com sucesso!")
./main.go:95:		RedisClient:         rdb,
./go.mod:7:	github.com/go-redis/redis/v8 v8.11.5
./evaluator.go:33:// getCombinedFlagInfo busca os dados no Redis, com fallback para os microsserviços
./evaluator.go:37:	// 1. Tentar buscar do Cache (Redis)
./evaluator.go:38:	val, err := a.RedisClient.Get(ctx, cacheKey).Result()
./evaluator.go:60:		a.RedisClient.Set(ctx, cacheKey, jsonData, CACHE_TTL).Err()

## AWS / SQS / DYNAMODB
./README.md:16:6.  Envia *assincronamente* um evento da decisão para uma fila **AWS SQS**.
./README.md:23:* **Credenciais da AWS:** Para o SQS funcionar, seu terminal deve estar autenticado na AWS (ex: via `aws configure` ou variáveis de ambiente).
./README.md:56:    # Cole a URL da fila SQS que você criou no console da AWS
./README.md:57:    AWS_SQS_URL="[https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
./README.md:59:    # Região da sua fila SQS
./README.md:60:    AWS_REGION="us-east-1" 
./README.md:102:**4. Verifique a Fila SQS:** Após fazer as chamadas acima, vá até o console da AWS, abra sua fila SQS e verifique se as mensagens (`EvaluationEvent`) estão chegando.
./sqs.go:9:	"github.com/aws/aws-sdk-go/service/sqs"
./sqs.go:20:// sendEvaluationEvent envia um evento para a fila SQS
./sqs.go:23:	if a.SqsSvc == nil || a.SqsQueueURL == "" {
./sqs.go:24:		log.Printf("[SQS_DISABLED] Evento: User '%s', Flag '%s', Result '%t'", userID, flagName, result)
./sqs.go:37:		log.Printf("Erro ao serializar evento SQS: %v", err)
./sqs.go:42:	_, err = a.SqsSvc.SendMessage(&sqs.SendMessageInput{
./sqs.go:43:		MessageBody: aws.String(string(body)),
./sqs.go:44:		QueueUrl:    aws.String(a.SqsQueueURL),
./sqs.go:48:		log.Printf("Erro ao enviar mensagem para SQS: %v", err)
./sqs.go:50:		log.Printf("Evento de avaliação enviado para SQS (Flag: %s)", flagName)
./main.go:12:	"github.com/aws/aws-sdk-go/service/sqs"
./main.go:23:	SqsSvc              *sqs.SQS
./main.go:24:	SqsQueueURL         string
./main.go:54:	// SQS é opcional no dev local, mas obrigatório em prod
./main.go:55:	sqsQueueURL := os.Getenv("AWS_SQS_URL")
./main.go:56:	awsRegion := os.Getenv("AWS_REGION")
./main.go:57:	if sqsQueueURL == "" {
./main.go:58:		log.Println("Atenção: AWS_SQS_URL não definida. Eventos não serão enviados.")
./main.go:60:	if awsRegion == "" && sqsQueueURL != "" {
./main.go:61:		log.Fatal("AWS_REGION deve ser definida para usar SQS")
./main.go:77:	// Cliente SQS (AWS SDK)
./main.go:78:	var sqsSvc *sqs.SQS
./main.go:79:	if sqsQueueURL != "" {
./main.go:80:		sess, err := session.NewSession(&aws.Config{Region: aws.String(awsRegion)})
./main.go:84:		sqsSvc = sqs.New(sess)
./main.go:85:		log.Println("Cliente SQS inicializado com sucesso.")
./main.go:96:		SqsSvc:              sqsSvc,
./main.go:97:		SqsQueueURL:         sqsQueueURL,
./handlers.go:47:	// 3. Enviar evento para SQS (assincronamente)


============================================================
SERVIÇO: analytics-service
============================================================

## PORTAS / LISTEN
./.git/hooks/post-update.sample:4:# dumb transports.
./.git/hooks/pre-commit.sample:29:	# even required, for portability to Solaris 10's /usr/bin/tr), since
./.git/hooks/pre-commit.sample:39:To be portable it is advisable to rename the file.
./.git/hooks/fsmonitor-watchman.sample:26:	die "Unsupported query-fsmonitor hook version '$version'.\n" .
./.git/hooks/pre-rebase.sample:124:    Then you can delete it.  More importantly, you should not
./README.md:45:# Porta que este serviço (health check) irá rodar
./README.md:46:PORT="8005"
./README.md:66:gunicorn --bind 0.0.0.0:8005 app:app
./README.md:68:O servidor estará rodando em `http://localhost:8005`. Você verá logs no terminal assim que o worker SQS iniciar e (eventualmente) processar mensagens.
./README.md:76:curl http://localhost:8005/health
./README.md:84:curl "http://localhost:8004/evaluate?user_id=test-user-1&flag_name=enable-new-dashboard"
./README.md:85:curl "http://localhost:8004/evaluate?user_id=test-user-2&flag_name=enable-new-dashboard"
./app.py:1:import os
./app.py:2:import sys
./app.py:3:import threading
./app.py:4:import json
./app.py:5:import uuid
./app.py:6:import time
./app.py:7:import logging
./app.py:8:import boto3
./app.py:9:from botocore.exceptions import NoCredentialsError, ClientError
./app.py:10:from flask import Flask, jsonify
./app.py:11:from dotenv import load_dotenv
./app.py:134:# Isso garante que ele inicie tanto com 'flask run' quanto com 'gunicorn'
./app.py:138:    port = int(os.getenv("PORT", 8005))
./app.py:139:    app.run(host='0.0.0.0', port=port, debug=False)
./requirements.txt:2:gunicorn==20.1.0
./Dockerfile:13:    && pip install --no-cache-dir gunicorn
./Dockerfile:19:CMD ["gunicorn", "--bind", "0.0.0.0:8005", "app:app"]

## VARIÁVEIS DE AMBIENTE
./README.md:6:1.  Ouvir constantemente a fila do **AWS SQS** (que o `evaluation-service` preenche).
./README.md:8:3.  Gravar os dados de análise em uma tabela do **AWS DynamoDB**.
./README.md:13:* **Credenciais da AWS:** Este serviço **DEVE** ter credenciais da AWS para acessar SQS e DynamoDB. Configure-as em seu terminal (via `aws configure`) ou defina as variáveis de ambiente:
./README.md:14:    * `AWS_ACCESS_KEY_ID`
./README.md:15:    * `AWS_SECRET_ACCESS_KEY`
./README.md:16:    * `AWS_SESSION_TOKEN` (se estiver usando o AWS Academy)
./README.md:17:* **Recursos da AWS:** Você precisa ter criado a Fila SQS e a Tabela DynamoDB no console.
./README.md:19:## 🚀 Preparando o DynamoDB
./README.md:21:Este serviço espera que uma tabela específica exista no DynamoDB.
./README.md:29:aws dynamodb create-table \
./README.md:49:# Cole a URL da fila SQS que você criou
./README.md:50:AWS_SQS_URL="httpsiso://[sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
./README.md:52:# Nome da tabela DynamoDB que você criou
./README.md:53:AWS_DYNAMODB_TABLE="ToggleMasterAnalytics"
./README.md:55:# Região dos seus serviços SQS e DynamoDB
./README.md:56:AWS_REGION="us-east-1"
./README.md:68:O servidor estará rodando em `http://localhost:8005`. Você verá logs no terminal assim que o worker SQS iniciar e (eventualmente) processar mensagens.
./README.md:87:- **Alternativa:** Envie uma mensagem manualmente pelo Console da AWS SQS.
./README.md:91:No terminal do `analytics-service`, você deverá ver os logs aparecendo, indicando que as mensagens foram recebidas e salvas no DynamoDB:
./README.md:93:INFO:Iniciando o worker SQS...
./README.md:96:INFO:Evento ... (Flag: enable-new-dashboard) salvo no DynamoDB.
./README.md:98:INFO:Evento ... (Flag: enable-new-dashboard) salvo no DynamoDB.
./README.md:101:**4. Verifique o DynamoDB:**
./README.md:103:Vá até o console da AWS, abra o **DynamoDB**, selecione a tabela `ToggleMasterAnalytics` e clique em "Explore table items".
./app.py:21:AWS_REGION = os.getenv("AWS_REGION")
./app.py:22:SQS_QUEUE_URL = os.getenv("AWS_SQS_URL")
./app.py:23:DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")
./app.py:25:if not all([AWS_REGION, SQS_QUEUE_URL, DYNAMODB_TABLE_NAME]):
./app.py:26:    log.critical("Erro: AWS_REGION, AWS_SQS_URL, e AWS_DYNAMODB_TABLE devem ser definidos.")
./app.py:32:    session = boto3.Session(region_name=AWS_REGION)
./app.py:33:    sqs_client = session.client("sqs")
./app.py:34:    dynamodb_client = session.client("dynamodb")
./app.py:35:    log.info(f"Clientes Boto3 inicializados na região {AWS_REGION}")
./app.py:44:# --- SQS Worker ---
./app.py:47:    """ Processa uma única mensagem SQS e a insere no DynamoDB """
./app.py:52:        # Gera um ID único para o item no DynamoDB
./app.py:55:        # Constrói o item no formato do DynamoDB
./app.py:64:        # Insere no DynamoDB
./app.py:65:        dynamodb_client.put_item(
./app.py:66:            TableName=DYNAMODB_TABLE_NAME,
./app.py:70:        log.info(f"Evento {event_id} (Flag: {body['flag_name']}) salvo no DynamoDB.")
./app.py:73:        sqs_client.delete_message(
./app.py:74:            QueueUrl=SQS_QUEUE_URL,
./app.py:82:        log.error(f"Erro do Boto3 (DynamoDB ou SQS) ao processar {message['MessageId']}: {e}")
./app.py:88:def sqs_worker_loop():
./app.py:89:    """ Loop principal do worker que ouve a fila SQS """
./app.py:90:    log.info("Iniciando o worker SQS...")
./app.py:94:            response = sqs_client.receive_message(
./app.py:95:                QueueUrl=SQS_QUEUE_URL,
./app.py:111:            log.error(f"Erro do Boto3 no loop principal do SQS: {e}")
./app.py:114:            log.error(f"Erro inesperado no loop principal do SQS: {e}")
./app.py:123:    # Uma verificação de saúde real poderia checar a conexão com o DynamoDB/SQS
./app.py:129:    """ Inicia o worker SQS em uma thread separada """
./app.py:130:    worker_thread = threading.Thread(target=sqs_worker_loop, daemon=True)
./app.py:133:# Inicia o worker SQS em uma thread de background
./app.py:138:    port = int(os.getenv("PORT", 8005))

## ENDPOINTS HTTP

## CHAMADAS HTTP
./.git/config:7:	url = https://github.com/FIAP-TCs/analytics-service.git
./.git/logs/refs/heads/main:1:0000000000000000000000000000000000000000 212d7e9b7e50f881c4022bc9e8d2722f08a2a3e2 wellk <wellk@tc-fiap.(none)> 1779210388 -0300	clone: from https://github.com/FIAP-TCs/analytics-service.git
./.git/logs/refs/remotes/origin/HEAD:1:0000000000000000000000000000000000000000 212d7e9b7e50f881c4022bc9e8d2722f08a2a3e2 wellk <wellk@tc-fiap.(none)> 1779210388 -0300	clone: from https://github.com/FIAP-TCs/analytics-service.git
./.git/logs/HEAD:1:0000000000000000000000000000000000000000 212d7e9b7e50f881c4022bc9e8d2722f08a2a3e2 wellk <wellk@tc-fiap.(none)> 1779210388 -0300	clone: from https://github.com/FIAP-TCs/analytics-service.git
./.git/hooks/fsmonitor-watchman.sample:8:# (https://facebook.github.io/watchman/) with git to speed up detecting
./README.md:12:* [Python](https://www.python.org/) (versão 3.9 ou superior)
./README.md:50:AWS_SQS_URL="httpsiso://[sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
./README.md:68:O servidor estará rodando em `http://localhost:8005`. Você verá logs no terminal assim que o worker SQS iniciar e (eventualmente) processar mensagens.
./README.md:76:curl http://localhost:8005/health
./README.md:84:curl "http://localhost:8004/evaluate?user_id=test-user-1&flag_name=enable-new-dashboard"
./README.md:85:curl "http://localhost:8004/evaluate?user_id=test-user-2&flag_name=enable-new-dashboard"

## POSTGRES / REDIS

## AWS / SQS / DYNAMODB
./README.md:6:1.  Ouvir constantemente a fila do **AWS SQS** (que o `evaluation-service` preenche).
./README.md:8:3.  Gravar os dados de análise em uma tabela do **AWS DynamoDB**.
./README.md:13:* **Credenciais da AWS:** Este serviço **DEVE** ter credenciais da AWS para acessar SQS e DynamoDB. Configure-as em seu terminal (via `aws configure`) ou defina as variáveis de ambiente:
./README.md:14:    * `AWS_ACCESS_KEY_ID`
./README.md:15:    * `AWS_SECRET_ACCESS_KEY`
./README.md:16:    * `AWS_SESSION_TOKEN` (se estiver usando o AWS Academy)
./README.md:17:* **Recursos da AWS:** Você precisa ter criado a Fila SQS e a Tabela DynamoDB no console.
./README.md:19:## 🚀 Preparando o DynamoDB
./README.md:21:Este serviço espera que uma tabela específica exista no DynamoDB.
./README.md:29:aws dynamodb create-table \
./README.md:49:# Cole a URL da fila SQS que você criou
./README.md:50:AWS_SQS_URL="httpsiso://[sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
./README.md:52:# Nome da tabela DynamoDB que você criou
./README.md:53:AWS_DYNAMODB_TABLE="ToggleMasterAnalytics"
./README.md:55:# Região dos seus serviços SQS e DynamoDB
./README.md:56:AWS_REGION="us-east-1"
./README.md:68:O servidor estará rodando em `http://localhost:8005`. Você verá logs no terminal assim que o worker SQS iniciar e (eventualmente) processar mensagens.
./README.md:87:- **Alternativa:** Envie uma mensagem manualmente pelo Console da AWS SQS.
./README.md:91:No terminal do `analytics-service`, você deverá ver os logs aparecendo, indicando que as mensagens foram recebidas e salvas no DynamoDB:
./README.md:93:INFO:Iniciando o worker SQS...
./README.md:96:INFO:Evento ... (Flag: enable-new-dashboard) salvo no DynamoDB.
./README.md:98:INFO:Evento ... (Flag: enable-new-dashboard) salvo no DynamoDB.
./README.md:101:**4. Verifique o DynamoDB:**
./README.md:103:Vá até o console da AWS, abra o **DynamoDB**, selecione a tabela `ToggleMasterAnalytics` e clique em "Explore table items".
./app.py:8:import boto3
./app.py:21:AWS_REGION = os.getenv("AWS_REGION")
./app.py:22:SQS_QUEUE_URL = os.getenv("AWS_SQS_URL")
./app.py:23:DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")
./app.py:25:if not all([AWS_REGION, SQS_QUEUE_URL, DYNAMODB_TABLE_NAME]):
./app.py:26:    log.critical("Erro: AWS_REGION, AWS_SQS_URL, e AWS_DYNAMODB_TABLE devem ser definidos.")
./app.py:29:# --- Clientes Boto3 ---
./app.py:32:    session = boto3.Session(region_name=AWS_REGION)
./app.py:33:    sqs_client = session.client("sqs")
./app.py:34:    dynamodb_client = session.client("dynamodb")
./app.py:35:    log.info(f"Clientes Boto3 inicializados na região {AWS_REGION}")
./app.py:40:    log.critical(f"Erro ao inicializar o Boto3: {e}")
./app.py:44:# --- SQS Worker ---
./app.py:47:    """ Processa uma única mensagem SQS e a insere no DynamoDB """
./app.py:52:        # Gera um ID único para o item no DynamoDB
./app.py:55:        # Constrói o item no formato do DynamoDB
./app.py:64:        # Insere no DynamoDB
./app.py:65:        dynamodb_client.put_item(
./app.py:66:            TableName=DYNAMODB_TABLE_NAME,
./app.py:70:        log.info(f"Evento {event_id} (Flag: {body['flag_name']}) salvo no DynamoDB.")
./app.py:73:        sqs_client.delete_message(
./app.py:74:            QueueUrl=SQS_QUEUE_URL,
./app.py:82:        log.error(f"Erro do Boto3 (DynamoDB ou SQS) ao processar {message['MessageId']}: {e}")
./app.py:88:def sqs_worker_loop():
./app.py:89:    """ Loop principal do worker que ouve a fila SQS """
./app.py:90:    log.info("Iniciando o worker SQS...")
./app.py:94:            response = sqs_client.receive_message(
./app.py:95:                QueueUrl=SQS_QUEUE_URL,
./app.py:111:            log.error(f"Erro do Boto3 no loop principal do SQS: {e}")
./app.py:114:            log.error(f"Erro inesperado no loop principal do SQS: {e}")
./app.py:123:    # Uma verificação de saúde real poderia checar a conexão com o DynamoDB/SQS
./app.py:129:    """ Inicia o worker SQS em uma thread separada """
./app.py:130:    worker_thread = threading.Thread(target=sqs_worker_loop, daemon=True)
./app.py:133:# Inicia o worker SQS em uma thread de background
./requirements.txt:4:boto3==1.26.50

