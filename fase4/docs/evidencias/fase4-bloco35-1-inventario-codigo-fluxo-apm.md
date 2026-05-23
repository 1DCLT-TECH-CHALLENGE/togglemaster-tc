# Fase 4 - BLOCO 35.1 - Inventário de código e fluxo E2E para APM/tracing

## Objetivo

Mapear o código, endpoints, dependências, imagens e fluxo E2E antes de implementar instrumentação OpenTelemetry real.

Este bloco não altera recursos Kubernetes, não aplica manifests e não modifica código de aplicação.

Data: Sat May 23 05:28:25 PM -03 2026

## Estado Git e cluster

```text
7e7d7e6 (HEAD -> main, origin/main) docs: inventory phase 4 apm tracing
06e44df docs: validate phase 4 otel collector
601ec5a feat: add phase 4 otel collector gitops
9e4fe3e docs: validate promtail logs in loki
539c098 docs: validate loki writable storage fix
2702a34 fix: mount writable var directory for loki
63f1918 docs: validate loki writable storage fix
05a6499 docs: diagnose loki crashloop
65724af docs: diagnose loki sync prune without pyyaml
69e8c64 docs: diagnose loki sync prune
7fad6dc docs: stabilize cluster after lab transition
38c433d docs: stabilize cluster after lab transition
NAME                                  SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-dashboards              Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
observability-kube-prometheus-stack   Synced        Healthy                                                    default
observability-loki                    Synced        Healthy                                                    default
observability-namespace               Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
observability-otel-collector          Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
observability-promtail                Synced        Healthy                                                    default
togglemaster-dev                      Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS           IMAGES                                                                                     SELECTOR
deployment.apps/analytics-service    1/1     1            1           15h   analytics-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb    app.kubernetes.io/name=analytics-service
deployment.apps/auth-service         2/2     2            2           15h   auth-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb         app.kubernetes.io/name=auth-service
deployment.apps/evaluation-service   2/2     2            2           15h   evaluation-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb   app.kubernetes.io/name=evaluation-service
deployment.apps/flag-service         2/2     2            2           15h   flag-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb         app.kubernetes.io/name=flag-service
deployment.apps/targeting-service    2/2     2            2           15h   targeting-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb    app.kubernetes.io/name=targeting-service

NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/analytics-service    ClusterIP   172.20.81.122   <none>        8000/TCP   15h   app.kubernetes.io/name=analytics-service
service/auth-service         ClusterIP   172.20.222.48   <none>        8000/TCP   15h   app.kubernetes.io/name=auth-service
service/evaluation-service   ClusterIP   172.20.66.90    <none>        8000/TCP   15h   app.kubernetes.io/name=evaluation-service
service/flag-service         ClusterIP   172.20.51.154   <none>        8000/TCP   15h   app.kubernetes.io/name=flag-service
service/targeting-service    ClusterIP   172.20.90.181   <none>        8000/TCP   15h   app.kubernetes.io/name=targeting-service

NAME                                      READY   STATUS    RESTARTS      AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
pod/analytics-service-6946467b6b-m7dkk    1/1     Running   0             59m   10.10.35.35    ip-10-10-34-177.ec2.internal   <none>           <none>
pod/auth-service-584688f79d-4fvw5         1/1     Running   0             53m   10.10.52.161   ip-10-10-51-233.ec2.internal   <none>           <none>
pod/auth-service-584688f79d-lkmfd         1/1     Running   6 (53m ago)   57m   10.10.47.28    ip-10-10-34-177.ec2.internal   <none>           <none>
pod/evaluation-service-7949b95dd5-6vrk6   1/1     Running   0             20m   10.10.55.176   ip-10-10-61-91.ec2.internal    <none>           <none>
pod/evaluation-service-7949b95dd5-tkxrk   1/1     Running   3 (53m ago)   54m   10.10.34.105   ip-10-10-37-16.ec2.internal    <none>           <none>
pod/flag-service-7cd69f6bf9-6sv22         1/1     Running   0             53m   10.10.55.3     ip-10-10-51-233.ec2.internal   <none>           <none>
pod/flag-service-7cd69f6bf9-lvvzs         1/1     Running   3 (54m ago)   59m   10.10.36.164   ip-10-10-34-177.ec2.internal   <none>           <none>
pod/targeting-service-66d4bb78b6-ntdtf    1/1     Running   0             53m   10.10.49.16    ip-10-10-51-233.ec2.internal   <none>           <none>
pod/targeting-service-66d4bb78b6-xz4vl    1/1     Running   3 (54m ago)   59m   10.10.39.50    ip-10-10-34-177.ec2.internal   <none>           <none>
NAME                           SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-otel-collector   Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                         AGE   SELECTOR
otel-collector   ClusterIP   172.20.181.189   <none>        4317/TCP,4318/TCP,8888/TCP,8889/TCP,13133/TCP   10m   app.kubernetes.io/name=otel-collector
```

## Estrutura dos serviços

```text

==== auth-service ====
fase2/src/services/auth-service/db/init.sql
fase2/src/services/auth-service/Dockerfile
fase2/src/services/auth-service/go.mod
fase2/src/services/auth-service/go.sum
fase2/src/services/auth-service/handlers.go
fase2/src/services/auth-service/key.go
fase2/src/services/auth-service/main.go
fase2/src/services/auth-service/README.md

==== evaluation-service ====
fase2/src/services/evaluation-service/Dockerfile
fase2/src/services/evaluation-service/evaluator.go
fase2/src/services/evaluation-service/go.mod
fase2/src/services/evaluation-service/go.sum
fase2/src/services/evaluation-service/handlers.go
fase2/src/services/evaluation-service/main.go
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909
fase2/src/services/evaluation-service/README.md
fase2/src/services/evaluation-service/sqs.go
fase2/src/services/evaluation-service/types.go

==== analytics-service ====
fase2/src/services/analytics-service/app.py
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356
fase2/src/services/analytics-service/Dockerfile
fase2/src/services/analytics-service/__pycache__/app.cpython-311.pyc
fase2/src/services/analytics-service/README.md
fase2/src/services/analytics-service/requirements.txt

==== flag-service ====
fase2/src/services/flag-service/app.py
fase2/src/services/flag-service/db/init.sql
fase2/src/services/flag-service/Dockerfile
fase2/src/services/flag-service/README.md
fase2/src/services/flag-service/requirements.txt

==== targeting-service ====
fase2/src/services/targeting-service/app.py
fase2/src/services/targeting-service/db/init.sql
fase2/src/services/targeting-service/Dockerfile
fase2/src/services/targeting-service/README.md
fase2/src/services/targeting-service/requirements.txt
```

## Endpoints encontrados no código

```text
### Go endpoints / handlers
fase2/src/services/auth-service/README.md:51:curl http://localhost:8001/health
fase2/src/services/auth-service/main.go:53:	mux.HandleFunc("/health", app.healthHandler)
fase2/src/services/auth-service/main.go:56:	mux.HandleFunc("/validate", app.validateKeyHandler)
fase2/src/services/auth-service/main.go:60:	mux.Handle("/admin/keys", app.masterKeyAuthMiddleware(http.HandlerFunc(app.createKeyHandler)))
fase2/src/services/auth-service/main.go:63:	if err := http.ListenAndServe(":"+port, mux); err != nil {
fase2/src/services/auth-service/handlers.go:108:func (a *App) masterKeyAuthMiddleware(next http.Handler) http.Handler {
fase2/src/services/auth-service/handlers.go:109:	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
fase2/src/services/evaluation-service/README.md:8:1.  Recebe uma requisição (`/evaluate?user_id=...&flag_name=...`).
fase2/src/services/evaluation-service/README.md:82:curl http://localhost:8004/health
fase2/src/services/evaluation-service/README.md:90:curl "http://localhost:8004/evaluate?user_id=user-123&flag_name=enable-new-dashboard"
fase2/src/services/evaluation-service/README.md:96:curl "http://localhost:8004/evaluate?user_id=user-abc&flag_name=enable-new-dashboard"
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:105:	mux.HandleFunc("/health", app.healthHandler)
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:106:	mux.HandleFunc("/evaluate", app.evaluationHandler)
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:109:	if err := http.ListenAndServe(":"+port, mux); err != nil {
fase2/src/services/evaluation-service/main.go:124:	mux.HandleFunc("/health", app.healthHandler)
fase2/src/services/evaluation-service/main.go:125:	mux.HandleFunc("/evaluate", app.evaluationHandler)
fase2/src/services/evaluation-service/main.go:128:	if err := http.ListenAndServe(":"+port, mux); err != nil {
fase2/src/services/evaluation-service/evaluator.go:104:	url := fmt.Sprintf("%s/flags/%s", a.FlagServiceURL, flagName)
fase2/src/services/evaluation-service/evaluator.go:132:	url := fmt.Sprintf("%s/rules/%s", a.TargetingServiceURL, flagName)

### Python Flask/FastAPI endpoints
fase2/src/services/analytics-service/README.md:3:Este é o serviço de análise (analytics) do projeto ToggleMaster. Ele é um *worker* de backend e não possui uma API pública (exceto `/health`).
fase2/src/services/analytics-service/README.md:76:curl http://localhost:8005/health
fase2/src/services/analytics-service/app.py:10:from flask import Flask, jsonify
fase2/src/services/analytics-service/app.py:124:# --- Servidor Flask (Apenas para Health Check) ---
fase2/src/services/analytics-service/app.py:126:app = Flask(__name__)
fase2/src/services/analytics-service/app.py:128:@app.route('/health')
fase2/src/services/analytics-service/requirements.txt:1:Flask==2.2.2
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:10:from flask import Flask, jsonify
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:117:# --- Servidor Flask (Apenas para Health Check) ---
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:119:app = Flask(__name__)
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:121:@app.route('/health')
fase2/src/services/flag-service/README.md:5:**IMPORTANTE:** Este serviço é protegido e depende que o `auth-service` esteja rodando. Todas as requisições (exceto `/health`) exigem um header `Authorization: Bearer <sua-chave-api>`.
fase2/src/services/flag-service/README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/flags_db"
fase2/src/services/flag-service/README.md:67:curl http://localhost:8002/health
fase2/src/services/flag-service/README.md:74:curl http://localhost:8002/flags
fase2/src/services/flag-service/README.md:81:curl -X POST http://localhost:8002/flags \
fase2/src/services/flag-service/README.md:94:curl http://localhost:8002/flags \
fase2/src/services/flag-service/README.md:101:curl -X PUT http://localhost:8002/flags/enable-new-dashboard \
fase2/src/services/flag-service/app.py:7:from flask import Flask, request, jsonify
fase2/src/services/flag-service/app.py:19:app = Flask(__name__)
fase2/src/services/flag-service/app.py:69:@app.route('/health')
fase2/src/services/flag-service/app.py:73:@app.route('/flags', methods=['POST'])
fase2/src/services/flag-service/app.py:111:@app.route('/flags', methods=['GET'])
fase2/src/services/flag-service/app.py:130:@app.route('/flags/<string:name>', methods=['GET'])
fase2/src/services/flag-service/app.py:151:@app.route('/flags/<string:name>', methods=['PUT'])
fase2/src/services/flag-service/app.py:199:@app.route('/flags/<string:name>', methods=['DELETE'])
fase2/src/services/flag-service/requirements.txt:1:Flask==2.2.2
fase2/src/services/targeting-service/README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/targeting_db"
fase2/src/services/targeting-service/README.md:54:curl http://localhost:8003/health
fase2/src/services/targeting-service/README.md:60:curl -X POST http://localhost:8003/rules \
fase2/src/services/targeting-service/README.md:76:curl http://localhost:8003/rules/enable-new-dashboard \
fase2/src/services/targeting-service/README.md:83:curl -X PUT http://localhost:8003/rules/enable-new-dashboard \
fase2/src/services/targeting-service/app.py:8:from flask import Flask, request, jsonify
fase2/src/services/targeting-service/app.py:20:app = Flask(__name__)
fase2/src/services/targeting-service/app.py:67:@app.route('/health')
fase2/src/services/targeting-service/app.py:71:@app.route('/rules', methods=['POST'])
fase2/src/services/targeting-service/app.py:109:@app.route('/rules/<string:flag_name>', methods=['GET'])
fase2/src/services/targeting-service/app.py:130:@app.route('/rules/<string:flag_name>', methods=['PUT'])
fase2/src/services/targeting-service/app.py:177:@app.route('/rules/<string:flag_name>', methods=['DELETE'])
fase2/src/services/targeting-service/requirements.txt:1:Flask==2.2.2
```

## Chamadas HTTP internas e referências de services

```text
fase2/src/services/targeting-service/README.md:5:**IMPORTANTE:** Este serviço também é protegido e depende que o `auth-service` esteja rodando (ex: em `http://localhost:8001`).
fase2/src/services/targeting-service/README.md:9:* [Python](https://www.python.org/) (versão 3.9 ou superior)
fase2/src/services/targeting-service/README.md:10:* [PostgreSQL](https://www.postgresql.org/download/)
fase2/src/services/targeting-service/README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
fase2/src/services/targeting-service/README.md:46:    O servidor estará rodando em `http://localhost:8003`.
fase2/src/services/targeting-service/README.md:54:curl http://localhost:8003/health
fase2/src/services/targeting-service/README.md:60:curl -X POST http://localhost:8003/rules \
fase2/src/services/targeting-service/README.md:76:curl http://localhost:8003/rules/enable-new-dashboard \
fase2/src/services/targeting-service/README.md:83:curl -X PUT http://localhost:8003/rules/enable-new-dashboard \
fase2/src/services/targeting-service/app.py:24:AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL")
fase2/src/services/targeting-service/app.py:26:if not DATABASE_URL or not AUTH_SERVICE_URL:
fase2/src/services/targeting-service/app.py:27:    log.critical("Erro: DATABASE_URL e AUTH_SERVICE_URL devem ser definidos.")
fase2/src/services/targeting-service/app.py:48:            validate_url = f"{AUTH_SERVICE_URL}/validate"
fase2/src/services/targeting-service/app.py:49:            response = requests.get(validate_url, headers={"Authorization": auth_header}, timeout=3)
fase2/src/services/targeting-service/app.py:55:        except requests.exceptions.Timeout:
fase2/src/services/targeting-service/app.py:58:        except requests.exceptions.RequestException as e:
fase2/src/services/evaluation-service/README.md:20:* [Go](https://go.dev/doc/install) (versão 1.21 ou superior)
fase2/src/services/evaluation-service/README.md:21:* [Redis](https://redis.io/docs/getting-started/installation/) (rodando localmente ou em Docker)
fase2/src/services/evaluation-service/README.md:32:    curl -X POST http://localhost:8001/admin/keys \
fase2/src/services/evaluation-service/README.md:49:    FLAG_SERVICE_URL="http://localhost:8002"
fase2/src/services/evaluation-service/README.md:50:    TARGETING_SERVICE_URL="http://localhost:8003"
fase2/src/services/evaluation-service/README.md:53:    SERVICE_API_KEY="SUA_CHAVE_DE_SERVICO"
fase2/src/services/evaluation-service/README.md:57:    AWS_SQS_URL="[https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
fase2/src/services/evaluation-service/README.md:72:    O servidor estará rodando em `http://localhost:8004`.
fase2/src/services/evaluation-service/README.md:82:curl http://localhost:8004/health
fase2/src/services/evaluation-service/README.md:90:curl "http://localhost:8004/evaluate?user_id=user-123&flag_name=enable-new-dashboard"
fase2/src/services/evaluation-service/README.md:96:curl "http://localhost:8004/evaluate?user_id=user-abc&flag_name=enable-new-dashboard"
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:44:	flagSvcURL := os.Getenv("FLAG_SERVICE_URL")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:46:		log.Fatal("FLAG_SERVICE_URL deve ser definida")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:49:	targetingSvcURL := os.Getenv("TARGETING_SERVICE_URL")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:51:		log.Fatal("TARGETING_SERVICE_URL deve ser definida")
fase2/src/services/evaluation-service/main.go:45:	flagSvcURL := os.Getenv("FLAG_SERVICE_URL")
fase2/src/services/evaluation-service/main.go:47:		log.Fatal("FLAG_SERVICE_URL deve ser definida")
fase2/src/services/evaluation-service/main.go:50:	targetingSvcURL := os.Getenv("TARGETING_SERVICE_URL")
fase2/src/services/evaluation-service/main.go:52:		log.Fatal("TARGETING_SERVICE_URL deve ser definida")
fase2/src/services/evaluation-service/evaluator.go:106:	apiKey := os.Getenv("SERVICE_API_KEY")
fase2/src/services/evaluation-service/evaluator.go:107:	req, _ := http.NewRequest("GET", url, nil)
fase2/src/services/evaluation-service/evaluator.go:133:	apiKey := os.Getenv("SERVICE_API_KEY") // Usa a mesma chave
fase2/src/services/evaluation-service/evaluator.go:134:	req, _ := http.NewRequest("GET", url, nil)
fase2/src/services/auth-service/README.md:7:* [Go](https://go.dev/doc/install) (versão 1.21 ou superior)
fase2/src/services/auth-service/README.md:8:* [PostgreSQL](https://www.postgresql.org/download/) (rodando localmente ou em um contêiner Docker)
fase2/src/services/auth-service/README.md:43:    O servidor estará rodando em `http://localhost:8001`.
fase2/src/services/auth-service/README.md:51:curl http://localhost:8001/health
fase2/src/services/auth-service/README.md:59:curl -X POST http://localhost:8001/admin/keys \
fase2/src/services/auth-service/README.md:78:curl http://localhost:8001/validate \
fase2/src/services/auth-service/README.md:87:curl http://localhost:8001/validate \
fase2/src/services/flag-service/README.md:9:* [Python](https://www.python.org/) (versão 3.9 ou superior)
fase2/src/services/flag-service/README.md:10:* [PostgreSQL](https://www.postgresql.org/download/) (rodando localmente ou em um contêiner Docker)
fase2/src/services/flag-service/README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
fase2/src/services/flag-service/README.md:46:    O servidor estará rodando em `http://localhost:8002`.
fase2/src/services/flag-service/README.md:54:    curl -X POST http://localhost:8001/admin/keys \
fase2/src/services/flag-service/README.md:67:curl http://localhost:8002/health
fase2/src/services/flag-service/README.md:74:curl http://localhost:8002/flags
fase2/src/services/flag-service/README.md:81:curl -X POST http://localhost:8002/flags \
fase2/src/services/flag-service/README.md:94:curl http://localhost:8002/flags \
fase2/src/services/flag-service/README.md:101:curl -X PUT http://localhost:8002/flags/enable-new-dashboard \
fase2/src/services/flag-service/app.py:23:AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL")
fase2/src/services/flag-service/app.py:25:if not DATABASE_URL or not AUTH_SERVICE_URL:
fase2/src/services/flag-service/app.py:26:    log.critical("Erro: DATABASE_URL e AUTH_SERVICE_URL devem ser definidos.")
fase2/src/services/flag-service/app.py:49:            validate_url = f"{AUTH_SERVICE_URL}/validate"
fase2/src/services/flag-service/app.py:50:            response = requests.get(validate_url, headers={"Authorization": auth_header}, timeout=3)
fase2/src/services/flag-service/app.py:56:        except requests.exceptions.Timeout:
fase2/src/services/flag-service/app.py:59:        except requests.exceptions.RequestException as e:
fase2/src/services/analytics-service/README.md:12:* [Python](https://www.python.org/) (versão 3.9 ou superior)
fase2/src/services/analytics-service/README.md:50:AWS_SQS_URL="httpsiso://[sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
fase2/src/services/analytics-service/README.md:68:O servidor estará rodando em `http://localhost:8005`. Você verá logs no terminal assim que o worker SQS iniciar e (eventualmente) processar mensagens.
fase2/src/services/analytics-service/README.md:76:curl http://localhost:8005/health
fase2/src/services/analytics-service/README.md:84:curl "http://localhost:8004/evaluate?user_id=test-user-1&flag_name=enable-new-dashboard"
fase2/src/services/analytics-service/README.md:85:curl "http://localhost:8004/evaluate?user_id=test-user-2&flag_name=enable-new-dashboard"
fase3/gitops/apps/togglemaster-dev-application.yaml:19:    server: https://kubernetes.default.svc
fase3/gitops/base/configmap.yaml:11:  AUTH_SERVICE_URL: http://auth-service:8000
fase3/gitops/base/configmap.yaml:12:  FLAG_SERVICE_URL: http://flag-service:8000
fase3/gitops/base/configmap.yaml:13:  TARGETING_SERVICE_URL: http://targeting-service:8000
fase3/gitops/base/configmap.yaml:17:  AWS_SQS_URL: https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events
fase3/gitops/base/evaluation-service.yaml:35:            - name: SERVICE_API_KEY
fase3/gitops/base/evaluation-service.yaml:39:                  key: SERVICE_API_KEY
fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml:11:    - repoURL: https://prometheus-community.github.io/helm-charts
fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml:22:    server: https://kubernetes.default.svc
fase4/gitops/apps/observability/dashboards-application.yaml:15:    server: https://kubernetes.default.svc
fase4/gitops/apps/observability/loki-application.yaml:11:    - repoURL: https://grafana.github.io/helm-charts
fase4/gitops/apps/observability/loki-application.yaml:23:    server: https://kubernetes.default.svc
fase4/gitops/apps/observability/promtail-application.yaml:11:    - repoURL: https://grafana.github.io/helm-charts
fase4/gitops/apps/observability/promtail-application.yaml:22:    server: https://kubernetes.default.svc
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:11:    - repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:22:    server: https://kubernetes.default.svc
fase4/gitops/apps/observability/otel-collector-application.yaml:16:    server: https://kubernetes.default.svc
fase4/gitops/apps/observability/namespace-application.yaml:15:    server: https://kubernetes.default.svc
fase4/gitops/observability/values/kube-prometheus-stack-values.yaml:34:      url: http://loki.observability.svc.cluster.local:3100
fase4/gitops/observability/values/promtail-values.yaml:3:    - url: http://loki.observability.svc.cluster.local:3100/loki/api/v1/push
```

## Variáveis de ambiente relevantes

```text
fase2/src/services/targeting-service/README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/targeting_db"
fase2/src/services/targeting-service/README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
fase2/src/services/targeting-service/app.py:23:DATABASE_URL = os.getenv("DATABASE_URL")
fase2/src/services/targeting-service/app.py:24:AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL")
fase2/src/services/targeting-service/app.py:26:if not DATABASE_URL or not AUTH_SERVICE_URL:
fase2/src/services/targeting-service/app.py:27:    log.critical("Erro: DATABASE_URL e AUTH_SERVICE_URL devem ser definidos.")
fase2/src/services/targeting-service/app.py:32:    pool = SimpleConnectionPool(1, 5, dsn=DATABASE_URL)
fase2/src/services/targeting-service/app.py:48:            validate_url = f"{AUTH_SERVICE_URL}/validate"
fase2/src/services/targeting-service/app.py:203:    port = int(os.getenv("PORT", 8003))
fase2/src/services/evaluation-service/README.md:30:    Este serviço precisa se autenticar no `flag-service` e no `targeting-service`. Você deve criar uma chave de API para ele usando o `auth-service` (com a `MASTER_KEY`).
fase2/src/services/evaluation-service/README.md:46:    REDIS_URL="redis://localhost:6379"
fase2/src/services/evaluation-service/README.md:49:    FLAG_SERVICE_URL="http://localhost:8002"
fase2/src/services/evaluation-service/README.md:50:    TARGETING_SERVICE_URL="http://localhost:8003"
fase2/src/services/evaluation-service/README.md:53:    SERVICE_API_KEY="SUA_CHAVE_DE_SERVICO"
fase2/src/services/evaluation-service/README.md:57:    AWS_SQS_URL="[https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:34:	port := os.Getenv("PORT")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:39:	redisURL := os.Getenv("REDIS_URL")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:41:		log.Fatal("REDIS_URL deve ser definida (ex: redis://localhost:6379)")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:44:	flagSvcURL := os.Getenv("FLAG_SERVICE_URL")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:46:		log.Fatal("FLAG_SERVICE_URL deve ser definida")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:49:	targetingSvcURL := os.Getenv("TARGETING_SERVICE_URL")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:51:		log.Fatal("TARGETING_SERVICE_URL deve ser definida")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:55:	sqsQueueURL := os.Getenv("AWS_SQS_URL")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:56:	awsRegion := os.Getenv("AWS_REGION")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:58:		log.Println("Atenção: AWS_SQS_URL não definida. Eventos não serão enviados.")
fase2/src/services/evaluation-service/main.go:35:	port := os.Getenv("PORT")
fase2/src/services/evaluation-service/main.go:40:	redisURL := os.Getenv("REDIS_URL")
fase2/src/services/evaluation-service/main.go:42:		log.Fatal("REDIS_URL deve ser definida (ex: redis://localhost:6379)")
fase2/src/services/evaluation-service/main.go:45:	flagSvcURL := os.Getenv("FLAG_SERVICE_URL")
fase2/src/services/evaluation-service/main.go:47:		log.Fatal("FLAG_SERVICE_URL deve ser definida")
fase2/src/services/evaluation-service/main.go:50:	targetingSvcURL := os.Getenv("TARGETING_SERVICE_URL")
fase2/src/services/evaluation-service/main.go:52:		log.Fatal("TARGETING_SERVICE_URL deve ser definida")
fase2/src/services/evaluation-service/main.go:56:	sqsQueueURL := os.Getenv("AWS_SQS_URL")
fase2/src/services/evaluation-service/main.go:57:	awsRegion := os.Getenv("AWS_REGION")
fase2/src/services/evaluation-service/main.go:59:		log.Println("Atenção: AWS_SQS_URL não definida. Eventos não serão enviados.")
fase2/src/services/evaluation-service/main.go:81:		awsEndpointURL := os.Getenv("AWS_ENDPOINT_URL")
fase2/src/services/evaluation-service/main.go:91:				os.Getenv("AWS_ACCESS_KEY_ID"),
fase2/src/services/evaluation-service/main.go:92:				os.Getenv("AWS_SECRET_ACCESS_KEY"),
fase2/src/services/evaluation-service/evaluator.go:106:	apiKey := os.Getenv("SERVICE_API_KEY")
fase2/src/services/evaluation-service/evaluator.go:133:	apiKey := os.Getenv("SERVICE_API_KEY") // Usa a mesma chave
fase2/src/services/auth-service/README.md:25:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/auth_db"
fase2/src/services/auth-service/README.md:31:    MASTER_KEY="admin-secreto-123"
fase2/src/services/auth-service/README.md:56:**2. Crie uma nova Chave de API (requer a MASTER_KEY):**
fase2/src/services/auth-service/main.go:24:	port := os.Getenv("PORT")
fase2/src/services/auth-service/main.go:29:	databaseURL := os.Getenv("DATABASE_URL")
fase2/src/services/auth-service/main.go:31:		log.Fatal("DATABASE_URL deve ser definida")
fase2/src/services/auth-service/main.go:34:	masterKey := os.Getenv("MASTER_KEY")
fase2/src/services/auth-service/main.go:36:		log.Fatal("MASTER_KEY deve ser definida")
fase2/src/services/auth-service/handlers.go:107:// masterKeyAuthMiddleware protege endpoints que só podem ser acessados com a MASTER_KEY
fase2/src/services/flag-service/README.md:28:    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/flags_db"
fase2/src/services/flag-service/README.md:34:    AUTH_SERVICE_URL="http://localhost:8001"
fase2/src/services/flag-service/app.py:22:DATABASE_URL = os.getenv("DATABASE_URL")
fase2/src/services/flag-service/app.py:23:AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL")
fase2/src/services/flag-service/app.py:25:if not DATABASE_URL or not AUTH_SERVICE_URL:
fase2/src/services/flag-service/app.py:26:    log.critical("Erro: DATABASE_URL e AUTH_SERVICE_URL devem ser definidos.")
fase2/src/services/flag-service/app.py:32:    pool = SimpleConnectionPool(1, 5, dsn=DATABASE_URL)
fase2/src/services/flag-service/app.py:49:            validate_url = f"{AUTH_SERVICE_URL}/validate"
fase2/src/services/flag-service/app.py:225:    port = int(os.getenv("PORT", 8002))
fase2/src/services/analytics-service/README.md:50:AWS_SQS_URL="httpsiso://[sqs.us-east-1.amazonaws.com/123456789012/sua-fila](https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila)"
fase2/src/services/analytics-service/README.md:53:AWS_DYNAMODB_TABLE="ToggleMasterAnalytics"
fase2/src/services/analytics-service/app.py:21:AWS_REGION = os.getenv("AWS_REGION")
fase2/src/services/analytics-service/app.py:22:SQS_QUEUE_URL = os.getenv("AWS_SQS_URL")
fase2/src/services/analytics-service/app.py:23:DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")
fase2/src/services/analytics-service/app.py:24:AWS_ENDPOINT_URL = os.getenv("AWS_ENDPOINT_URL")
fase2/src/services/analytics-service/app.py:27:    log.critical("Erro: AWS_REGION, AWS_SQS_URL, e AWS_DYNAMODB_TABLE devem ser definidos.")
fase2/src/services/analytics-service/app.py:145:    port = int(os.getenv("PORT", 8005))
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:21:AWS_REGION = os.getenv("AWS_REGION")
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:22:SQS_QUEUE_URL = os.getenv("AWS_SQS_URL")
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:23:DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:26:    log.critical("Erro: AWS_REGION, AWS_SQS_URL, e AWS_DYNAMODB_TABLE devem ser definidos.")
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:138:    port = int(os.getenv("PORT", 8005))
fase3/gitops/apps/togglemaster-dev-application.yaml:9:    environment: dev
fase3/gitops/overlays/dev/kustomization.yaml:9:      environment: dev
fase3/gitops/base/configmap.yaml:11:  AUTH_SERVICE_URL: http://auth-service:8000
fase3/gitops/base/configmap.yaml:12:  FLAG_SERVICE_URL: http://flag-service:8000
fase3/gitops/base/configmap.yaml:13:  TARGETING_SERVICE_URL: http://targeting-service:8000
fase3/gitops/base/configmap.yaml:15:  REDIS_URL: redis://togglemaster-dev-redis.hmdfss.ng.0001.use1.cache.amazonaws.com:6379
fase3/gitops/base/configmap.yaml:17:  AWS_SQS_URL: https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events
fase3/gitops/base/configmap.yaml:18:  AWS_DYNAMODB_TABLE: togglemaster-dev-ToggleMasterAnalytics
fase3/gitops/base/auth-service.yaml:35:            - name: DATABASE_URL
fase3/gitops/base/auth-service.yaml:39:                  key: AUTH_DATABASE_URL
fase3/gitops/base/auth-service.yaml:40:            - name: MASTER_KEY
fase3/gitops/base/auth-service.yaml:44:                  key: MASTER_KEY
fase3/gitops/base/targeting-service.yaml:35:            - name: DATABASE_URL
fase3/gitops/base/targeting-service.yaml:39:                  key: TARGETING_DATABASE_URL
fase3/gitops/base/evaluation-service.yaml:35:            - name: SERVICE_API_KEY
fase3/gitops/base/evaluation-service.yaml:39:                  key: SERVICE_API_KEY
fase3/gitops/base/flag-service.yaml:35:            - name: DATABASE_URL
fase3/gitops/base/flag-service.yaml:39:                  key: FLAGS_DATABASE_URL
```

## Dependências atuais

```text

==== fase2/src/services/auth-service/go.mod ====
module auth-service

go 1.21

require (
	github.com/jackc/pgx/v4 v4.18.3
	github.com/joho/godotenv v1.5.1
)

require (
	github.com/jackc/chunkreader/v2 v2.0.1 // indirect
	github.com/jackc/pgconn v1.14.3 // indirect
	github.com/jackc/pgio v1.0.0 // indirect
	github.com/jackc/pgpassfile v1.0.0 // indirect
	github.com/jackc/pgproto3/v2 v2.3.3 // indirect
	github.com/jackc/pgservicefile v0.0.0-20221227161230-091c0ba34f0a // indirect
	github.com/jackc/pgtype v1.14.0 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	golang.org/x/crypto v0.20.0 // indirect
	golang.org/x/text v0.14.0 // indirect
)

==== fase2/src/services/evaluation-service/go.mod ====
module evaluation-service

go 1.21

require (
	github.com/aws/aws-sdk-go v1.51.10
	github.com/go-redis/redis/v8 v8.11.5
	github.com/joho/godotenv v1.5.1
)

require (
	github.com/cespare/xxhash/v2 v2.2.0 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/dgryski/go-rendezvous v0.0.0-20200823014737-9f7001d12a5f // indirect
	github.com/jmespath/go-jmespath v0.4.0 // indirect
	github.com/onsi/gomega v1.27.6 // indirect
	golang.org/x/net v0.21.0 // indirect
	golang.org/x/sys v0.17.0 // indirect
)

==== fase2/src/services/analytics-service/requirements.txt ====
Flask==2.2.2
gunicorn==20.1.0
python-dotenv==0.21.0
boto3==1.26.50
Werkzeug==2.3.8

==== fase2/src/services/flag-service/requirements.txt ====
Flask==2.2.2
psycopg2-binary==2.9.5
gunicorn==20.1.0
python-dotenv==0.21.0
requests==2.28.1
Werkzeug==2.3.8

==== fase2/src/services/targeting-service/requirements.txt ====
Flask==2.2.2
psycopg2-binary==2.9.5
gunicorn==20.1.0
python-dotenv==0.21.0
requests==2.28.1
Werkzeug==2.3.8
```

## Dockerfiles

```text

==== fase2/src/services/analytics-service/Dockerfile ====
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      gcc \
      libpq-dev \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python -m pip install --upgrade "pip<26" \
 && pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir gunicorn

COPY . .

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]

==== fase2/src/services/auth-service/Dockerfile ====
FROM golang:1.22 AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum* ./

RUN go mod download || true

COPY . .

RUN go build -o service .

FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/service /app/service

EXPOSE 8000

CMD ["/app/service"]

==== fase2/src/services/evaluation-service/Dockerfile ====
FROM golang:1.22 AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum* ./

RUN go mod download || true

COPY . .

RUN go build -o service .

FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/service /app/service

EXPOSE 8000

CMD ["/app/service"]

==== fase2/src/services/flag-service/Dockerfile ====
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      gcc \
      libpq-dev \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python -m pip install --upgrade "pip<26" \
 && pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir gunicorn

COPY . .

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]

==== fase2/src/services/targeting-service/Dockerfile ====
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      gcc \
      libpq-dev \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python -m pip install --upgrade "pip<26" \
 && pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir gunicorn

COPY . .

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
```

## GitOps atual

```text
fase3/gitops/apps/kustomization.yaml
fase3/gitops/apps/togglemaster-dev-application.yaml
fase3/gitops/base/analytics-service.yaml
fase3/gitops/base/auth-service.yaml
fase3/gitops/base/configmap.yaml
fase3/gitops/base/evaluation-service.yaml
fase3/gitops/base/flag-service.yaml
fase3/gitops/base/kustomization.yaml
fase3/gitops/base/namespace.yaml
fase3/gitops/base/targeting-service.yaml
fase3/gitops/overlays/dev/kustomization.yaml

---- trechos com image/env/deployment ----
fase3/gitops/overlays/dev/kustomization.yaml:12:  - name: auth-service
fase3/gitops/overlays/dev/kustomization.yaml:14:  - name: flag-service
fase3/gitops/overlays/dev/kustomization.yaml:16:  - name: targeting-service
fase3/gitops/overlays/dev/kustomization.yaml:18:  - name: evaluation-service
fase3/gitops/overlays/dev/kustomization.yaml:20:  - name: analytics-service
fase3/gitops/base/auth-service.yaml:2:kind: Deployment
fase3/gitops/base/auth-service.yaml:4:  name: auth-service
fase3/gitops/base/auth-service.yaml:7:    app.kubernetes.io/name: auth-service
fase3/gitops/base/auth-service.yaml:18:      app.kubernetes.io/name: auth-service
fase3/gitops/base/auth-service.yaml:22:        app.kubernetes.io/name: auth-service
fase3/gitops/base/auth-service.yaml:26:        - name: auth-service
fase3/gitops/base/auth-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/gitops/base/auth-service.yaml:30:            - containerPort: 8000
fase3/gitops/base/auth-service.yaml:31:          envFrom:
fase3/gitops/base/auth-service.yaml:34:          env:
fase3/gitops/base/auth-service.yaml:35:            - name: DATABASE_URL
fase3/gitops/base/auth-service.yaml:39:                  key: AUTH_DATABASE_URL
fase3/gitops/base/auth-service.yaml:45:          readinessProbe:
fase3/gitops/base/auth-service.yaml:51:          livenessProbe:
fase3/gitops/base/auth-service.yaml:61:  name: auth-service
fase3/gitops/base/auth-service.yaml:65:    app.kubernetes.io/name: auth-service
fase3/gitops/base/targeting-service.yaml:2:kind: Deployment
fase3/gitops/base/targeting-service.yaml:4:  name: targeting-service
fase3/gitops/base/targeting-service.yaml:7:    app.kubernetes.io/name: targeting-service
fase3/gitops/base/targeting-service.yaml:18:      app.kubernetes.io/name: targeting-service
fase3/gitops/base/targeting-service.yaml:22:        app.kubernetes.io/name: targeting-service
fase3/gitops/base/targeting-service.yaml:26:        - name: targeting-service
fase3/gitops/base/targeting-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/gitops/base/targeting-service.yaml:30:            - containerPort: 8000
fase3/gitops/base/targeting-service.yaml:31:          envFrom:
fase3/gitops/base/targeting-service.yaml:34:          env:
fase3/gitops/base/targeting-service.yaml:35:            - name: DATABASE_URL
fase3/gitops/base/targeting-service.yaml:39:                  key: TARGETING_DATABASE_URL
fase3/gitops/base/targeting-service.yaml:40:          readinessProbe:
fase3/gitops/base/targeting-service.yaml:46:          livenessProbe:
fase3/gitops/base/targeting-service.yaml:56:  name: targeting-service
fase3/gitops/base/targeting-service.yaml:60:    app.kubernetes.io/name: targeting-service
fase3/gitops/base/evaluation-service.yaml:2:kind: Deployment
fase3/gitops/base/evaluation-service.yaml:4:  name: evaluation-service
fase3/gitops/base/evaluation-service.yaml:7:    app.kubernetes.io/name: evaluation-service
fase3/gitops/base/evaluation-service.yaml:18:      app.kubernetes.io/name: evaluation-service
fase3/gitops/base/evaluation-service.yaml:22:        app.kubernetes.io/name: evaluation-service
fase3/gitops/base/evaluation-service.yaml:26:        - name: evaluation-service
fase3/gitops/base/evaluation-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/gitops/base/evaluation-service.yaml:30:            - containerPort: 8000
fase3/gitops/base/evaluation-service.yaml:31:          envFrom:
fase3/gitops/base/evaluation-service.yaml:34:          env:
fase3/gitops/base/evaluation-service.yaml:35:            - name: SERVICE_API_KEY
fase3/gitops/base/evaluation-service.yaml:39:                  key: SERVICE_API_KEY
fase3/gitops/base/evaluation-service.yaml:55:          readinessProbe:
fase3/gitops/base/evaluation-service.yaml:61:          livenessProbe:
fase3/gitops/base/evaluation-service.yaml:71:  name: evaluation-service
fase3/gitops/base/evaluation-service.yaml:75:    app.kubernetes.io/name: evaluation-service
fase3/gitops/base/analytics-service.yaml:2:kind: Deployment
fase3/gitops/base/analytics-service.yaml:4:  name: analytics-service
fase3/gitops/base/analytics-service.yaml:7:    app.kubernetes.io/name: analytics-service
fase3/gitops/base/analytics-service.yaml:18:      app.kubernetes.io/name: analytics-service
fase3/gitops/base/analytics-service.yaml:22:        app.kubernetes.io/name: analytics-service
fase3/gitops/base/analytics-service.yaml:26:        - name: analytics-service
fase3/gitops/base/analytics-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/gitops/base/analytics-service.yaml:30:            - containerPort: 8000
fase3/gitops/base/analytics-service.yaml:31:          envFrom:
fase3/gitops/base/analytics-service.yaml:34:          env:
fase3/gitops/base/analytics-service.yaml:50:          readinessProbe:
fase3/gitops/base/analytics-service.yaml:56:          livenessProbe:
fase3/gitops/base/analytics-service.yaml:66:  name: analytics-service
fase3/gitops/base/analytics-service.yaml:70:    app.kubernetes.io/name: analytics-service
fase3/gitops/base/flag-service.yaml:2:kind: Deployment
fase3/gitops/base/flag-service.yaml:4:  name: flag-service
fase3/gitops/base/flag-service.yaml:7:    app.kubernetes.io/name: flag-service
fase3/gitops/base/flag-service.yaml:18:      app.kubernetes.io/name: flag-service
fase3/gitops/base/flag-service.yaml:22:        app.kubernetes.io/name: flag-service
fase3/gitops/base/flag-service.yaml:26:        - name: flag-service
fase3/gitops/base/flag-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/gitops/base/flag-service.yaml:30:            - containerPort: 8000
fase3/gitops/base/flag-service.yaml:31:          envFrom:
fase3/gitops/base/flag-service.yaml:34:          env:
fase3/gitops/base/flag-service.yaml:35:            - name: DATABASE_URL
fase3/gitops/base/flag-service.yaml:39:                  key: FLAGS_DATABASE_URL
fase3/gitops/base/flag-service.yaml:40:          readinessProbe:
fase3/gitops/base/flag-service.yaml:46:          livenessProbe:
fase3/gitops/base/flag-service.yaml:56:  name: flag-service
fase3/gitops/base/flag-service.yaml:60:    app.kubernetes.io/name: flag-service
fase4/gitops/observability/otel-collector/deployment.yaml:2:kind: Deployment
fase4/gitops/observability/otel-collector/deployment.yaml:28:          image: otel/opentelemetry-collector-contrib:0.111.0
fase4/gitops/observability/otel-collector/deployment.yaml:34:              containerPort: 4317
fase4/gitops/observability/otel-collector/deployment.yaml:36:              containerPort: 4318
fase4/gitops/observability/otel-collector/deployment.yaml:38:              containerPort: 8888
fase4/gitops/observability/otel-collector/deployment.yaml:40:              containerPort: 8889
fase4/gitops/observability/otel-collector/deployment.yaml:42:              containerPort: 13133
fase4/gitops/observability/otel-collector/deployment.yaml:43:          readinessProbe:
fase4/gitops/observability/otel-collector/deployment.yaml:51:          livenessProbe:
fase4/gitops/observability/values/opentelemetry-collector-values.yaml:3:image:
fase4/gitops/observability/values/opentelemetry-collector-values.yaml:18:    containerPort: 4317
fase4/gitops/observability/values/opentelemetry-collector-values.yaml:23:    containerPort: 4318
fase4/gitops/observability/values/opentelemetry-collector-values.yaml:28:    containerPort: 8889
```

## Imagens runtime

```text
analytics-service-6946467b6b-m7dkk	analytics-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb 
auth-service-584688f79d-4fvw5	auth-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb 
auth-service-584688f79d-lkmfd	auth-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb 
evaluation-service-7949b95dd5-6vrk6	evaluation-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb 
evaluation-service-7949b95dd5-tkxrk	evaluation-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb 
flag-service-7cd69f6bf9-6sv22	flag-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb 
flag-service-7cd69f6bf9-lvvzs	flag-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb 
targeting-service-66d4bb78b6-ntdtf	targeting-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb 
targeting-service-66d4bb78b6-xz4vl	targeting-service=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb 
```

## Workflows/scripts de build

```text
fase3/gitops/apps/kustomization.yaml
fase3/gitops/apps/togglemaster-dev-application.yaml
fase3/gitops/base/analytics-service.yaml
fase3/gitops/base/auth-service.yaml
fase3/gitops/base/configmap.yaml
fase3/gitops/base/evaluation-service.yaml
fase3/gitops/base/flag-service.yaml
fase3/gitops/base/kustomization.yaml
fase3/gitops/base/namespace.yaml
fase3/gitops/base/targeting-service.yaml
fase3/gitops/overlays/dev/kustomization.yaml
fase3/local/scripts/01_validate_phase3_offline.sh
fase3/local/scripts/18_checkpoint_retomada_pre_fase4.sh
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh
fase3/logs/fase3-argocd-apps-render.yaml
fase3/logs/fase3-bloco20-argocd-apps-render.yaml
fase3/logs/fase3-bloco20-gitops-base-render.yaml
fase3/logs/fase3-bloco20-gitops-dev-render.yaml
fase3/logs/fase3-gitops-base-render.yaml
fase3/logs/fase3-gitops-dev-render-pos-ecr.yaml
fase3/logs/fase3-gitops-dev-render-predeploy.yaml
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml
fase3/logs/fase3-gitops-dev-render-runtime-check.yaml
fase3/logs/fase3-gitops-dev-render-runtime-configmap.yaml
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml
fase3/logs/fase3-gitops-dev-render.yaml
fase4/gitops/apps/observability/dashboards-application.yaml
fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml
fase4/gitops/apps/observability/kustomization.yaml
fase4/gitops/apps/observability/loki-application.yaml
fase4/gitops/apps/observability/namespace-application.yaml
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml
fase4/gitops/apps/observability/otel-collector-application.yaml
fase4/gitops/apps/observability/promtail-application.yaml
fase4/gitops/observability/dashboards/kustomization.yaml
fase4/gitops/observability/dashboards/togglemaster-grafana-dashboard.yaml
fase4/gitops/observability/namespace/kustomization.yaml
fase4/gitops/observability/namespace/namespace.yaml
fase4/gitops/observability/otel-collector/configmap.yaml
fase4/gitops/observability/otel-collector/deployment.yaml
fase4/gitops/observability/otel-collector/kustomization.yaml
fase4/gitops/observability/otel-collector/servicemonitor.yaml
fase4/gitops/observability/otel-collector/service.yaml
fase4/gitops/observability/values/kube-prometheus-stack-values.yaml
fase4/gitops/observability/values/loki-lab-writable-values.yaml
fase4/gitops/observability/values/loki-values.yaml
fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/gitops/observability/values/promtail-values.yaml
fase4/scripts/23_inventory_phase4_stack.sh
fase4/scripts/24_capacity_gate_observability.sh
fase4/scripts/25_plan_observability_capacity_fix.sh
fase4/scripts/26_patch_terraform_eks_capacity.sh
fase4/scripts/27_terraform_plan_eks_capacity.sh
fase4/scripts/28_terraform_apply_eks_capacity.sh
fase4/scripts/29_prepare_observability_gitops.sh
fase4/scripts/30_apply_prometheus_grafana_argocd.sh
fase4/scripts/31_validate_grafana_access.sh
fase4/scripts/32_apply_grafana_dashboard.sh
fase4/scripts/33_10_finalize_loki_writable_fix.sh
fase4/scripts/33_12_finalize_promtail_loki.sh
fase4/scripts/33_2_fix_loki_light_mode_v2.sh
fase4/scripts/33_4_stabilize_cluster_after_lab_transition.sh
fase4/scripts/33_6_sync_prune_loki.sh
fase4/scripts/33_7_loki_sync_prune_no_pyyaml.sh
fase4/scripts/33_8_diagnose_loki_crashloop.sh
fase4/scripts/34_apply_otel_collector_gitops.sh
fase4/scripts/35_0_inventory_apm_tracing.sh
fase4/scripts/35_1_inventory_code_flow_apm.sh
fase4/tmp/bloco33-12/apps-render.yaml
fase4/tmp/bloco33-1/loki-render.yaml
fase4/tmp/bloco33-1/loki-values.after.yaml
fase4/tmp/bloco33-1/loki-values.before.yaml
fase4/tmp/bloco33-2/loki-render.yaml
fase4/tmp/bloco33/apps-render.yaml
.github/workflows/phase3-gitops-validate.yml
.github/workflows/phase3-security-scan.yml
.github/workflows/phase3-terraform-validate.yml

---- trechos build/push/ecr/docker ----
.github/workflows/phase3-gitops-validate.yml:32:        run: kubectl kustomize fase3/gitops/base > /tmp/phase3-gitops-base.yaml
.github/workflows/phase3-gitops-validate.yml:35:        run: kubectl kustomize fase3/gitops/overlays/dev > /tmp/phase3-gitops-dev.yaml
.github/workflows/phase3-gitops-validate.yml:38:        run: kubectl kustomize fase3/gitops/apps > /tmp/phase3-argocd-apps.yaml
fase3/README.md:37:- ECR para os 5 microsserviços;
fase3/README.md:66:- push de imagem para ECR real;
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:12:SECRET_NAME="togglemaster-runtime-secret"
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:279:  kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" \
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:334:append_cmd "ArgoCD application" kubectl get application togglemaster-dev -n argocd -o wide
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:338:ARGO_STATUS="$(kubectl get application togglemaster-dev -n argocd -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:361:kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" >/dev/null
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:366:  echo "ERRO: MASTER_KEY ausente no Secret $SECRET_NAME."
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:599:append_cmd "ArgoCD final" kubectl get application togglemaster-dev -n argocd -o wide
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:602:ARGO_STATUS_FINAL="$(kubectl get application togglemaster-dev -n argocd -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
fase3/local/scripts/01_validate_phase3_offline.sh:51:kubectl kustomize fase3/gitops/base > "$LOG_DIR/fase3-bloco20-gitops-base-render.yaml"
fase3/local/scripts/01_validate_phase3_offline.sh:56:kubectl kustomize fase3/gitops/overlays/dev > "$LOG_DIR/fase3-bloco20-gitops-dev-render.yaml"
fase3/local/scripts/01_validate_phase3_offline.sh:61:kubectl kustomize fase3/gitops/apps > "$LOG_DIR/fase3-bloco20-argocd-apps-render.yaml"
fase3/local/scripts/01_validate_phase3_offline.sh:62:grep -nE '^kind: |^  name: |repoURL|path:|targetRevision:' "$LOG_DIR/fase3-bloco20-argocd-apps-render.yaml" | head -80
fase3/local/scripts/01_validate_phase3_offline.sh:75:SECRET_FINDINGS="$LOG_DIR/fase3-bloco20-secret-findings.txt"
fase3/local/scripts/01_validate_phase3_offline.sh:86:  _shared fase3 > "$SECRET_FINDINGS" || true
fase3/local/scripts/01_validate_phase3_offline.sh:88:cat "$SECRET_FINDINGS"
fase3/local/scripts/01_validate_phase3_offline.sh:91:  grep -v 'manage_master_user_password = true' "$SECRET_FINDINGS" \
fase3/local/scripts/01_validate_phase3_offline.sh:122:- `kubectl kustomize fase3/gitops/base`;
fase3/local/scripts/01_validate_phase3_offline.sh:123:- `kubectl kustomize fase3/gitops/overlays/dev`;
fase3/local/scripts/01_validate_phase3_offline.sh:124:- `kubectl kustomize fase3/gitops/apps`;
fase3/local/scripts/01_validate_phase3_offline.sh:156:- `logs/fase3-bloco20-argocd-apps-render.yaml`
fase3/local/scripts/18_checkpoint_retomada_pre_fase4.sh:39:- Recursos AWS principais: ECR, RDS, ElastiCache, SQS e DynamoDB.
fase3/local/scripts/18_checkpoint_retomada_pre_fase4.sh:177:run_and_record "Applications ArgoCD" kubectl get applications -n argocd -o wide
fase3/local/scripts/18_checkpoint_retomada_pre_fase4.sh:178:run_and_record "Application togglemaster-dev" kubectl get application togglemaster-dev -n argocd -o wide
fase3/local/scripts/18_checkpoint_retomada_pre_fase4.sh:189:run_and_record "ECR repositories ToggleMaster" aws ecr describe-repositories \
fase3/local/scripts/18_checkpoint_retomada_pre_fase4.sh:222:ARGO_STATUS="$(kubectl get application togglemaster-dev -n argocd -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
fase3/logs/fase3-gitops-base-render.yaml:112:        image: REPLACE_WITH_ECR_ANALYTICS_SERVICE_IMAGE
fase3/logs/fase3-gitops-base-render.yaml:153:        image: REPLACE_WITH_ECR_AUTH_SERVICE_IMAGE
fase3/logs/fase3-gitops-base-render.yaml:194:        image: REPLACE_WITH_ECR_EVALUATION_SERVICE_IMAGE
fase3/logs/fase3-gitops-base-render.yaml:235:        image: REPLACE_WITH_ECR_FLAG_SERVICE_IMAGE
fase3/logs/fase3-gitops-base-render.yaml:276:        image: REPLACE_WITH_ECR_TARGETING_SERVICE_IMAGE
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:132:        - name: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:135:              key: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:145:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:198:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:248:        - name: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:251:              key: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:261:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:309:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-predeploy.yaml:357:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-configmap.yaml:129:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-configmap.yaml:171:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-configmap.yaml:213:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-configmap.yaml:255:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-configmap.yaml:297:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/logs/fase3-bloco20-argocd-apps-render.yaml:9:  namespace: argocd
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:132:        - name: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:135:              key: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:145:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:198:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:248:        - name: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:251:              key: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:261:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:309:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-secretrefs.yaml:357:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-check.yaml:125:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-check.yaml:167:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-check.yaml:209:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-check.yaml:251:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-runtime-check.yaml:293:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/logs/fase3-bloco20-gitops-base-render.yaml:112:        image: REPLACE_WITH_ECR_ANALYTICS_SERVICE_IMAGE
fase3/logs/fase3-bloco20-gitops-base-render.yaml:153:        image: REPLACE_WITH_ECR_AUTH_SERVICE_IMAGE
fase3/logs/fase3-bloco20-gitops-base-render.yaml:194:        image: REPLACE_WITH_ECR_EVALUATION_SERVICE_IMAGE
fase3/logs/fase3-bloco20-gitops-base-render.yaml:235:        image: REPLACE_WITH_ECR_FLAG_SERVICE_IMAGE
fase3/logs/fase3-bloco20-gitops-base-render.yaml:276:        image: REPLACE_WITH_ECR_TARGETING_SERVICE_IMAGE
fase3/logs/fase3-argocd-apps-render.yaml:9:  namespace: argocd
fase3/logs/fase3-gitops-dev-render-pos-ecr.yaml:125:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-pos-ecr.yaml:167:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-pos-ecr.yaml:209:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-pos-ecr.yaml:251:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-pos-ecr.yaml:293:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/logs/fase3-bloco20-gitops-dev-render.yaml:125:        image: REPLACE_WITH_ECR_ANALYTICS_SERVICE_IMAGE
fase3/logs/fase3-bloco20-gitops-dev-render.yaml:167:        image: REPLACE_WITH_ECR_AUTH_SERVICE_IMAGE
fase3/logs/fase3-bloco20-gitops-dev-render.yaml:209:        image: REPLACE_WITH_ECR_EVALUATION_SERVICE_IMAGE
fase3/logs/fase3-bloco20-gitops-dev-render.yaml:251:        image: REPLACE_WITH_ECR_FLAG_SERVICE_IMAGE
fase3/logs/fase3-bloco20-gitops-dev-render.yaml:293:        image: REPLACE_WITH_ECR_TARGETING_SERVICE_IMAGE
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:137:        - name: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:140:              key: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:150:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:208:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:263:        - name: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:266:              key: AWS_SECRET_ACCESS_KEY
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:276:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:329:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/logs/fase3-gitops-dev-render-rollout-strategy.yaml:382:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/logs/fase3-gitops-dev-render.yaml:125:        image: REPLACE_WITH_ECR_ANALYTICS_SERVICE_IMAGE
fase3/logs/fase3-gitops-dev-render.yaml:167:        image: REPLACE_WITH_ECR_AUTH_SERVICE_IMAGE
fase3/logs/fase3-gitops-dev-render.yaml:209:        image: REPLACE_WITH_ECR_EVALUATION_SERVICE_IMAGE
fase3/logs/fase3-gitops-dev-render.yaml:251:        image: REPLACE_WITH_ECR_FLAG_SERVICE_IMAGE
fase3/logs/fase3-gitops-dev-render.yaml:293:        image: REPLACE_WITH_ECR_TARGETING_SERVICE_IMAGE
fase3/docs/evidencias/fase3-fechamento-offline.md:44:- `kubectl kustomize fase3/gitops/base`;
fase3/docs/evidencias/fase3-fechamento-offline.md:45:- `kubectl kustomize fase3/gitops/overlays/dev`;
fase3/docs/evidencias/fase3-fechamento-offline.md:46:- `kubectl kustomize fase3/gitops/apps`;
fase3/docs/evidencias/fase3-fechamento-offline.md:77:- push de imagem para ECR real;
fase3/docs/evidencias/fase3-bloco01-fundacao-offline.md:43:- `fase3/terraform/modules/argocd`
fase3/docs/evidencias/fase3-bloco19-4-diagnostico-async.md:36:$ kubectl get application togglemaster-dev -n argocd -o wide
fase3/docs/evidencias/fase3-bloco19-4-diagnostico-async.md:68:analytics-service    1/1     1            1           12h   analytics-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb    app.kubernetes.io/name=analytics-service
fase3/docs/evidencias/fase3-bloco19-4-diagnostico-async.md:69:auth-service         2/2     2            2           12h   auth-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb         app.kubernetes.io/name=auth-service
fase3/docs/evidencias/fase3-bloco19-4-diagnostico-async.md:70:evaluation-service   2/2     2            2           12h   evaluation-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb   app.kubernetes.io/name=evaluation-service
fase3/docs/evidencias/fase3-bloco19-4-diagnostico-async.md:71:flag-service         2/2     2            2           12h   flag-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb         app.kubernetes.io/name=flag-service
fase3/docs/evidencias/fase3-bloco19-4-diagnostico-async.md:72:targeting-service    2/2     2            2           12h   targeting-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb    app.kubernetes.io/name=targeting-service
fase3/docs/evidencias/fase3-aws-bloco17c-configmap-runtime-nao-sensivel.md:45:- AWS_SECRET;
fase3/docs/evidencias/fase3-aws-bloco17c-configmap-runtime-nao-sensivel.md:57:- Deployments ainda apontando para imagens ECR reais com tag c0f03bb;
fase3/docs/evidencias/fase3-bloco17-gitops-overlay-dev-offline.md:26:- `kubectl kustomize fase3/gitops/base`
fase3/docs/evidencias/fase3-aws-blocos-01-03-identificacao-lab.md:41:- ECR: sem repositórios;
fase3/docs/evidencias/fase3-aws-blocos-01-03-identificacao-lab.md:83:- push de imagem para ECR real;
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:1:# Fase 3 - AWS Academy - BLOCO AWS-16A - GitOps atualizado com imagens ECR
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:7:Registrar a atualização dos manifests GitOps para apontar para as imagens reais publicadas no Amazon ECR.
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:11:Após o BLOCO AWS-15C, as cinco imagens Docker dos microsserviços foram publicadas no ECR com a tag c0f03bb.
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:15:- REPLACE_WITH_ECR_AUTH_SERVICE_IMAGE
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:16:- REPLACE_WITH_ECR_FLAG_SERVICE_IMAGE
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:17:- REPLACE_WITH_ECR_TARGETING_SERVICE_IMAGE
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:18:- REPLACE_WITH_ECR_EVALUATION_SERVICE_IMAGE
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:19:- REPLACE_WITH_ECR_ANALYTICS_SERVICE_IMAGE
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:25:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:26:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:27:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:28:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:29:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:43:- não restaram placeholders REPLACE_WITH_ECR;
fase3/docs/evidencias/fase3-aws-bloco16a-gitops-imagens-ecr.md:46:- os cinco Deployments renderizados apontam para as imagens ECR corretas.
fase3/docs/evidencias/fase3-aws-bloco06-terraform-plan.md:42:- ECR repositories;
fase3/docs/evidencias/fase3-aws-bloco06-terraform-plan.md:66:- push de imagem para ECR;
fase3/docs/evidencias/fase3-aws-bloco07-apply-timeout-eks.md:22:- ECR repositories;
fase3/docs/evidencias/fase3-bloco18-checkpoint-retomada-pre-fase4.md:20:- Recursos AWS principais: ECR, RDS, ElastiCache, SQS e DynamoDB.
fase3/docs/evidencias/fase3-bloco18-checkpoint-retomada-pre-fase4.md:196:$ kubectl get applications -n argocd -o wide
fase3/docs/evidencias/fase3-bloco18-checkpoint-retomada-pre-fase4.md:205:$ kubectl get application togglemaster-dev -n argocd -o wide
fase3/docs/evidencias/fase3-bloco18-checkpoint-retomada-pre-fase4.md:253:### ECR repositories ToggleMaster
fase3/docs/evidencias/fase3-bloco18-checkpoint-retomada-pre-fase4.md:256:$ aws ecr describe-repositories --region us-east-1 --query repositories[?contains(repositoryName, `togglemaster`) || contains(repositoryName, `auth`) || contains(repositoryName, `flag`) || contains(repositoryName, `targeting`) || contains(repositoryName, `evaluation`) || contains(repositoryName, `analytics`)].repositoryName --output table
fase3/docs/evidencias/fase3-aws-bloco17ae-deploy-gitops-e2e-cloud.md:20:Após a infraestrutura AWS da Fase 3 ter sido criada via Terraform e validada sem drift, os cinco microsserviços foram buildados e publicados no Amazon ECR.
fase3/docs/evidencias/fase3-aws-bloco17ae-deploy-gitops-e2e-cloud.md:22:Os manifests GitOps foram atualizados para apontar para as imagens reais do ECR e para consumir:
fase3/docs/evidencias/fase3-aws-bloco14-inventario-pre-deploy.md:37:## ECR
fase3/docs/evidencias/fase3-aws-bloco14-inventario-pre-deploy.md:39:Repositórios ECR existentes:
fase3/docs/evidencias/fase3-aws-bloco14-inventario-pre-deploy.md:85:Ainda não existem imagens Docker publicadas no ECR, portanto o próximo bloco deve tratar build, tag e push das imagens dos cinco microsserviços.
fase3/docs/evidencias/fase3-aws-bloco17b-runtime-env-vars.md:78:- AWS_SECRET_ACCESS_KEY
fase3/docs/evidencias/fase3-aws-bloco13-retomada-lab.md:16:- AWS_SECRET_ACCESS_KEY presente
fase3/docs/evidencias/fase3-bloco21-github-actions-offline.md:35:- `kubectl kustomize fase3/gitops/base`;
fase3/docs/evidencias/fase3-bloco21-github-actions-offline.md:36:- `kubectl kustomize fase3/gitops/overlays/dev`;
fase3/docs/evidencias/fase3-bloco21-github-actions-offline.md:37:- `kubectl kustomize fase3/gitops/apps`.
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:1:# Fase 3 - AWS Academy - BLOCO AWS-15C - Build e push das imagens para ECR
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:7:Registrar o build e push das imagens Docker dos cinco microsserviços para o Amazon ECR.
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:11:O inventário pré-deploy confirmou que os cinco repositórios ECR existiam, mas ainda estavam sem imagens.
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:13:Foi realizado login Docker no ECR e em seguida build/push das imagens a partir dos serviços consolidados da Fase 2.
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:15:## Registry ECR
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:25:- c0f03bb
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:41:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:42:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:43:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:44:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:45:- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:51:O ECR confirmou a presença da tag c0f03bb em todos os repositórios.
fase3/docs/evidencias/fase3-aws-bloco15c-build-push-ecr.md:55:O comando describe-images também exibiu imagens sem tag. Essas entradas são artefatos/attestations gerados pelo processo de build/push, mas a tag c0f03bb foi confirmada nas cinco imagens principais.
fase3/docs/evidencias/fase3-aws-bloco16d-runtime-secrets-inventario.md:26:- AWS_SECRET_ACCESS_KEY presente;
fase3/docs/evidencias/fase3-aws-bloco17a-inspecao-secrets-gitops.md:24:Os manifests base já apontam para imagens reais do ECR com a tag `c0f03bb`.
fase3/docs/evidencias/fase3-bloco07-ecr-module-offline.md:1:# Fase 3 - BLOCO 07 - Módulo ECR offline
fase3/docs/evidencias/fase3-bloco07-ecr-module-offline.md:7:Criar e conectar o módulo Terraform de ECR para os microsserviços da Fase 3, ainda sem conexão com AWS.
fase3/docs/evidencias/fase3-bloco07-ecr-module-offline.md:47:- push de imagens para ECR real.
fase3/docs/evidencias/fase3-bloco07-ecr-module-offline.md:51:Módulo ECR criado e conectado ao ambiente `dev` para validação local posterior.
fase3/docs/evidencias/fase3-bloco20-validacao-offline.md:15:- `kubectl kustomize fase3/gitops/base`;
fase3/docs/evidencias/fase3-bloco20-validacao-offline.md:16:- `kubectl kustomize fase3/gitops/overlays/dev`;
fase3/docs/evidencias/fase3-bloco20-validacao-offline.md:17:- `kubectl kustomize fase3/gitops/apps`;
fase3/docs/evidencias/fase3-bloco20-validacao-offline.md:49:- `logs/fase3-bloco20-argocd-apps-render.yaml`
fase3/docs/evidencias/fase3-bloco16-gitops-base-offline.md:22:Os manifests usam imagens placeholder `REPLACE_WITH_ECR_*`.
fase3/docs/evidencias/fase3-bloco16-gitops-base-offline.md:24:Essas imagens serão substituídas posteriormente por URLs reais de ECR após a etapa AWS Academy/Terraform/ECR.
fase3/docs/evidencias/fase3-bloco19-validacao-apps-pre-fase4.md:56:$ kubectl get application togglemaster-dev -n argocd -o wide
fase3/docs/evidencias/fase3-bloco19-validacao-apps-pre-fase4.md:410:$ kubectl get application togglemaster-dev -n argocd -o wide
fase3/docs/evidencias/fase3-bloco19-5-refresh-pod-aws-creds.md:39:$ kubectl get application togglemaster-dev -n argocd -o wide
fase3/docs/evidencias/fase3-bloco19-5-refresh-pod-aws-creds.md:146:$ kubectl get application togglemaster-dev -n argocd -o wide
fase3/docs/operacional/pre-aws-academy-checklist.md:41:- `kubectl kustomize fase3/gitops/base`;
fase3/docs/operacional/pre-aws-academy-checklist.md:42:- `kubectl kustomize fase3/gitops/overlays/dev`;
fase3/docs/operacional/pre-aws-academy-checklist.md:43:- `kubectl kustomize fase3/gitops/apps`;
fase3/docs/operacional/pre-aws-academy-checklist.md:59:- push de imagem para ECR real;
fase3/docs/operacional/pre-aws-academy-checklist.md:92:11. disponibilidade de ECR;
fase3/gitops/apps/togglemaster-dev-application.yaml:5:  namespace: argocd
fase3/gitops/apps/kustomization.yaml:1:apiVersion: kustomize.config.k8s.io/v1beta1
fase3/gitops/overlays/dev/kustomization.yaml:1:apiVersion: kustomize.config.k8s.io/v1beta1
fase3/gitops/base/auth-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase3/gitops/base/targeting-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase3/gitops/base/evaluation-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase3/gitops/base/evaluation-service.yaml:45:            - name: AWS_SECRET_ACCESS_KEY
fase3/gitops/base/evaluation-service.yaml:49:                  key: AWS_SECRET_ACCESS_KEY
fase3/gitops/base/analytics-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase3/gitops/base/analytics-service.yaml:40:            - name: AWS_SECRET_ACCESS_KEY
fase3/gitops/base/analytics-service.yaml:44:                  key: AWS_SECRET_ACCESS_KEY
fase3/gitops/base/flag-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase3/gitops/base/kustomization.yaml:1:apiVersion: kustomize.config.k8s.io/v1beta1
fase3/terraform/environments/dev/variables.tf:38:  description = "Microsserviços ToggleMaster que terão imagem no ECR e manifests Kubernetes."
fase3/terraform/environments/dev/main.tf:99:# - argocd
fase3/terraform/environments/dev/outputs.tf:62:  description = "Nomes dos repositórios ECR por serviço."
fase3/terraform/environments/dev/outputs.tf:67:  description = "URLs dos repositórios ECR por serviço."
fase3/terraform/environments/dev/outputs.tf:72:  description = "ARNs dos repositórios ECR por serviço."
fase3/terraform/modules/ecr/variables.tf:7:  description = "Lista de serviços que terão repositório ECR."
fase3/terraform/modules/ecr/variables.tf:29:  description = "Permite deletar repositórios ECR com imagens durante destroy em ambiente dev."
fase3/terraform/modules/ecr/outputs.tf:2:  description = "Nomes dos repositórios ECR."
fase3/terraform/modules/ecr/outputs.tf:7:  description = "URLs dos repositórios ECR."
fase3/terraform/modules/ecr/outputs.tf:12:  description = "ARNs dos repositórios ECR."
fase4/scripts/33_12_finalize_promtail_loki.sh:12:ARGO_NS="argocd"
fase4/scripts/31_validate_grafana_access.sh:45:kubectl get application observability-kube-prometheus-stack -n argocd -o wide
fase4/scripts/29_prepare_observability_gitops.sh:14:ARGO_NS="argocd"
fase4/scripts/29_prepare_observability_gitops.sh:83:- valida render com \`kustomize build\` e \`helm template\`;
fase4/scripts/29_prepare_observability_gitops.sh:85:- não executa \`argocd sync\`;
fase4/scripts/29_prepare_observability_gitops.sh:236:apiVersion: kustomize.config.k8s.io/v1beta1
fase4/scripts/29_prepare_observability_gitops.sh:578:apiVersion: kustomize.config.k8s.io/v1beta1
fase4/scripts/29_prepare_observability_gitops.sh:589:  namespace: argocd
fase4/scripts/29_prepare_observability_gitops.sh:591:    argocd.argoproj.io/sync-wave: "0"
fase4/scripts/29_prepare_observability_gitops.sh:614:  namespace: argocd
fase4/scripts/29_prepare_observability_gitops.sh:616:    argocd.argoproj.io/sync-wave: "10"
fase4/scripts/29_prepare_observability_gitops.sh:647:  namespace: argocd
fase4/scripts/29_prepare_observability_gitops.sh:649:    argocd.argoproj.io/sync-wave: "20"
fase4/scripts/29_prepare_observability_gitops.sh:680:  namespace: argocd
fase4/scripts/29_prepare_observability_gitops.sh:682:    argocd.argoproj.io/sync-wave: "21"
fase4/scripts/29_prepare_observability_gitops.sh:713:  namespace: argocd
fase4/scripts/29_prepare_observability_gitops.sh:715:    argocd.argoproj.io/sync-wave: "30"
fase4/scripts/29_prepare_observability_gitops.sh:738:  namespace: argocd
fase4/scripts/29_prepare_observability_gitops.sh:740:    argocd.argoproj.io/sync-wave: "30"
fase4/scripts/29_prepare_observability_gitops.sh:767:apiVersion: kustomize.config.k8s.io/v1beta1
fase4/scripts/29_prepare_observability_gitops.sh:818:record_cmd "Kustomize namespace observability" kubectl kustomize fase4/gitops/observability/namespace
fase4/scripts/29_prepare_observability_gitops.sh:819:record_cmd "Kustomize dashboards observability" kubectl kustomize fase4/gitops/observability/dashboards
fase4/scripts/29_prepare_observability_gitops.sh:820:record_cmd "Kustomize ArgoCD applications observability" kubectl kustomize fase4/gitops/apps/observability
fase4/scripts/29_prepare_observability_gitops.sh:887:- Nenhum \`argocd sync\` executado.
fase4/scripts/27_terraform_plan_eks_capacity.sh:79:    -e 's/(aws_secret_access_key|AWS_SECRET_ACCESS_KEY)([[:space:]]*=[[:space:]]*)"?[^"[:space:]]+"?/\1\2REDACTED/Ig' \
fase4/scripts/33_4_stabilize_cluster_after_lab_transition.sh:13:ARGO_NS="argocd"
fase4/scripts/23_inventory_phase4_stack.sh:14:ARGO_NS="argocd"
fase4/scripts/33_8_diagnose_loki_crashloop.sh:12:ARGO_NS="argocd"
fase4/scripts/33_2_fix_loki_light_mode_v2.sh:15:ARGO_NS="argocd"
fase4/scripts/33_2_fix_loki_light_mode_v2.sh:37:  "fase4/scripts/33_apply_loki_promtail_argocd.sh" \
fase4/scripts/33_2_fix_loki_light_mode_v2.sh:38:  "fase4/docs/evidencias/fase4-bloco33-loki-promtail-argocd.md" \
fase4/scripts/33_2_fix_loki_light_mode_v2.sh:224:kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true
fase4/scripts/35_0_inventory_apm_tracing.sh:11:ARGO_NS="argocd"
fase4/scripts/35_1_inventory_code_flow_apm.sh:13:ARGO_NS="argocd"
fase4/scripts/35_1_inventory_code_flow_apm.sh:145:  grep -RInE 'docker build|docker push|ECR|aws ecr|image tag|kubectl set image|kustomize|argocd|buildx|c0f03bb|github.sha' \
fase4/scripts/32_apply_grafana_dashboard.sh:11:ARGO_NS="argocd"
fase4/scripts/32_apply_grafana_dashboard.sh:61:kubectl kustomize fase4/gitops/observability/dashboards > "$TMP/dashboard-render.yaml"
fase4/scripts/32_apply_grafana_dashboard.sh:62:kubectl kustomize fase4/gitops/apps/observability > "$TMP/apps-render.yaml"
fase4/scripts/32_apply_grafana_dashboard.sh:64:echo "OK: kustomize render dos dashboards e apps passou."
fase4/scripts/34_apply_otel_collector_gitops.sh:13:ARGO_NS="argocd"
fase4/scripts/34_apply_otel_collector_gitops.sh:297:apiVersion: kustomize.config.k8s.io/v1beta1
fase4/scripts/34_apply_otel_collector_gitops.sh:313:  namespace: argocd
fase4/scripts/34_apply_otel_collector_gitops.sh:347:        text = "apiVersion: kustomize.config.k8s.io/v1beta1\nkind: Kustomization\nresources:\n" + resource + "\n"
fase4/scripts/34_apply_otel_collector_gitops.sh:357:apiVersion: kustomize.config.k8s.io/v1beta1
fase4/scripts/34_apply_otel_collector_gitops.sh:366:kubectl kustomize "$OTEL_DIR" > "$TMP/otel-render.yaml"
fase4/scripts/34_apply_otel_collector_gitops.sh:367:kubectl kustomize "$PHASE/gitops/apps/observability" > "$TMP/apps-render.yaml"
fase4/scripts/34_apply_otel_collector_gitops.sh:374:echo "OK: kustomize render passou."
fase4/scripts/34_apply_otel_collector_gitops.sh:437:  echo "kubectl kustomize $OTEL_DIR OK"
fase4/scripts/34_apply_otel_collector_gitops.sh:438:  echo "kubectl kustomize $PHASE/gitops/apps/observability OK"
fase4/scripts/34_apply_otel_collector_gitops.sh:471:kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true
fase4/scripts/24_capacity_gate_observability.sh:12:ARGO_NS="argocd"
fase4/scripts/33_6_sync_prune_loki.sh:12:ARGO_NS="argocd"
fase4/scripts/33_6_sync_prune_loki.sh:142:kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true
fase4/scripts/33_6_sync_prune_loki.sh:147:if command -v argocd >/dev/null 2>&1; then
fase4/scripts/33_6_sync_prune_loki.sh:148:  echo "argocd CLI encontrado."
fase4/scripts/33_6_sync_prune_loki.sh:150:  argocd app sync "$APP" --prune --grpc-web
fase4/scripts/33_6_sync_prune_loki.sh:155:  echo "argocd CLI não encontrado; usando patch operation no Application."
fase4/scripts/28_terraform_apply_eks_capacity.sh:84:    -e 's/(aws_secret_access_key|AWS_SECRET_ACCESS_KEY)([[:space:]]*=[[:space:]]*)"?[^"[:space:]]+"?/\1\2REDACTED/Ig' \
fase4/scripts/28_terraform_apply_eks_capacity.sh:460:record_cmd "ArgoCD application final" kubectl get application togglemaster-dev -n argocd -o wide
fase4/scripts/33_10_finalize_loki_writable_fix.sh:13:ARGO_NS="argocd"
fase4/scripts/33_10_finalize_loki_writable_fix.sh:228:kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true
fase4/scripts/33_7_loki_sync_prune_no_pyyaml.sh:12:ARGO_NS="argocd"
fase4/scripts/33_7_loki_sync_prune_no_pyyaml.sh:146:kubectl annotate application "$APP" -n "$ARGO_NS" argocd.argoproj.io/refresh=hard --overwrite || true
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:7:EVID="$PHASE/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md"
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:8:LOG="$PHASE/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.log"
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:11:ARGO_NS="argocd"
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:122:wait_argocd_app() {
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:181:  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd\.md$|^\?\? fase4/scripts/30_apply_prometheus_grafana_argocd\.sh$|^\?\? fase4/scripts/$' || true
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:196:record_cmd "Kustomize apps observability" kubectl kustomize fase4/gitops/apps/observability
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:204:wait_argocd_app "observability-namespace" 30 10
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:212:wait_argocd_app "observability-kube-prometheus-stack" 90 15
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:14:- valida render com `kustomize build` e `helm template`;
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:16:- não executa `argocd sync`;
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:70:$ kubectl get application togglemaster-dev -n argocd -o wide
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:98:argocd         argocd-application-controller-0                     1/1     Running   0          11h     10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:99:argocd         argocd-applicationset-controller-5b964db9cd-rl8kn   1/1     Running   0          11h     10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:100:argocd         argocd-dex-server-b8cc6d795-r658p                   1/1     Running   0          11h     10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:101:argocd         argocd-notifications-controller-597cccd4ff-q2p2l    1/1     Running   0          11h     10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:102:argocd         argocd-redis-675f9c4c99-ngqb4                       1/1     Running   0          11h     10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:103:argocd         argocd-repo-server-5c46694888-b4bqj                 1/1     Running   0          11h     10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:104:argocd         argocd-server-7f66865588-df8sl                      1/1     Running   0          11h     10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:174:$ kubectl kustomize fase4/gitops/observability/namespace
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:191:$ kubectl kustomize fase4/gitops/observability/dashboards
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:282:$ kubectl kustomize fase4/gitops/apps/observability
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:287:    argocd.argoproj.io/sync-wave: "30"
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:289:  namespace: argocd
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:310:    argocd.argoproj.io/sync-wave: "10"
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:312:  namespace: argocd
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:341:    argocd.argoproj.io/sync-wave: "20"
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:343:  namespace: argocd
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:372:    argocd.argoproj.io/sync-wave: "0"
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:374:  namespace: argocd
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:395:    argocd.argoproj.io/sync-wave: "30"
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:397:  namespace: argocd
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:426:    argocd.argoproj.io/sync-wave: "21"
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:428:  namespace: argocd
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8445:- Nenhum `argocd sync` executado.
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:90:argocd            Active   13h
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:104:$ kubectl get application togglemaster-dev -n argocd -o wide
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:117:argocd         argocd-application-controller-0                     1/1     Running   0          11h   10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:118:argocd         argocd-applicationset-controller-5b964db9cd-rl8kn   1/1     Running   0          11h   10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:119:argocd         argocd-dex-server-b8cc6d795-r658p                   1/1     Running   0          11h   10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:120:argocd         argocd-notifications-controller-597cccd4ff-q2p2l    1/1     Running   0          11h   10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:121:argocd         argocd-redis-675f9c4c99-ngqb4                       1/1     Running   0          11h   10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:122:argocd         argocd-repo-server-5c46694888-b4bqj                 1/1     Running   0          11h   10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:123:argocd         argocd-server-7f66865588-df8sl                      1/1     Running   0          11h   10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:149:analytics-service    1/1     1            1           13h   analytics-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb    app.kubernetes.io/name=analytics-service
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:150:auth-service         2/2     2            2           13h   auth-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb         app.kubernetes.io/name=auth-service
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:151:evaluation-service   2/2     2            2           13h   evaluation-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb   app.kubernetes.io/name=evaluation-service
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:152:flag-service         2/2     2            2           13h   flag-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb         app.kubernetes.io/name=flag-service
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:153:targeting-service    2/2     2            2           13h   targeting-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb    app.kubernetes.io/name=targeting-service
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:200:- argocd: 7 pods
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:472:- argocd: 7 pods
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:492:argocd         argocd-application-controller-0                     1/1     Running   0          11h   10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:493:argocd         argocd-applicationset-controller-5b964db9cd-rl8kn   1/1     Running   0          11h   10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:494:argocd         argocd-dex-server-b8cc6d795-r658p                   1/1     Running   0          11h   10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:495:argocd         argocd-notifications-controller-597cccd4ff-q2p2l    1/1     Running   0          11h   10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:496:argocd         argocd-redis-675f9c4c99-ngqb4                       1/1     Running   0          11h   10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:497:argocd         argocd-repo-server-5c46694888-b4bqj                 1/1     Running   0          11h   10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:498:argocd         argocd-server-7f66865588-df8sl                      1/1     Running   0          11h   10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md:528:$ kubectl get application togglemaster-dev -n argocd -o wide
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:22:?? fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:23:?? fase4/scripts/30_apply_prometheus_grafana_argocd.sh
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:65:$ retry_cmd 6 10 kubectl get application togglemaster-dev -n argocd -o wide
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:66:Tentativa 1/6: kubectl get application togglemaster-dev -n argocd -o wide
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:80:argocd         argocd-application-controller-0                     1/1     Running   0          11h   10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:81:argocd         argocd-applicationset-controller-5b964db9cd-rl8kn   1/1     Running   0          12h   10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:82:argocd         argocd-dex-server-b8cc6d795-r658p                   1/1     Running   0          12h   10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:83:argocd         argocd-notifications-controller-597cccd4ff-q2p2l    1/1     Running   0          12h   10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:84:argocd         argocd-redis-675f9c4c99-ngqb4                       1/1     Running   0          12h   10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:85:argocd         argocd-repo-server-5c46694888-b4bqj                 1/1     Running   0          12h   10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:86:argocd         argocd-server-7f66865588-df8sl                      1/1     Running   0          12h   10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:119:$ kubectl kustomize fase4/gitops/apps/observability
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:124:    argocd.argoproj.io/sync-wave: "30"
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:126:  namespace: argocd
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:147:    argocd.argoproj.io/sync-wave: "10"
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:149:  namespace: argocd
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:178:    argocd.argoproj.io/sync-wave: "20"
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:180:  namespace: argocd
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:209:    argocd.argoproj.io/sync-wave: "0"
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:211:  namespace: argocd
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:232:    argocd.argoproj.io/sync-wave: "30"
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:234:  namespace: argocd
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:263:    argocd.argoproj.io/sync-wave: "21"
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:265:  namespace: argocd
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:302:  namespace: argocd
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:304:    argocd.argoproj.io/sync-wave: "0"
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:333:  namespace: argocd
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:335:    argocd.argoproj.io/sync-wave: "10"
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:410:$ retry_bash 6 10 kubectl get applications -n "argocd" | grep -E 'observability|NAME'
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:411:Tentativa 1/6: kubectl get applications -n "argocd" | grep -E 'observability|NAME'
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:520:- argocd: 7
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:72:kubectl kustomize fase4/gitops/observability/otel-collector OK
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:73:kubectl kustomize fase4/gitops/apps/observability OK
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:197:argocd            Active   13h
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:211:$ kubectl get applications -n argocd -o wide
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:258:analytics-service    1/1     1            1           13h   analytics-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb    app.kubernetes.io/name=analytics-service
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:259:auth-service         2/2     2            2           13h   auth-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb         app.kubernetes.io/name=auth-service
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:260:evaluation-service   2/2     2            2           13h   evaluation-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb   app.kubernetes.io/name=evaluation-service
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:261:flag-service         2/2     2            2           13h   flag-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb         app.kubernetes.io/name=flag-service
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:262:targeting-service    2/2     2            2           13h   targeting-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb    app.kubernetes.io/name=targeting-service
fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md:272:89:      {"apiVersion":"v1","data":{"config.yaml":"\nauth_enabled: false\nbloom_build:\n  builder:\n    planner_address: \"\"\n  enabled: false\nbloom_gateway:\n  client:\n    addresses: \"\"\n  enabled: false\ncommon:\n  compactor_grpc_address: 'loki.observability.svc.cluster.local:9095'\n  path_prefix: /var/loki\n  replication_factor: 1\n  storage:\n    filesystem:\n      chunks_directory: /var/loki/chunks\n      rules_directory: /var/loki/rules\ncompactor:\n  delete_request_store: filesystem\n  retention_enabled: true\nfrontend:\n  scheduler_address: \"\"\n  tail_proxy_url: \"\"\nfrontend_worker:\n  scheduler_address: \"\"\nindex_gateway:\n  mode: simple\nlimits_config:\n  max_cache_freshness_per_query: 10m\n  query_timeout: 300s\n  reject_old_samples: true\n  reject_old_samples_max_age: 168h\n  retention_period: 24h\n  split_queries_by_interval: 15m\n  volume_enabled: true\nmemberlist:\n  join_members:\n  - loki-memberlist.observability.svc.cluster.local\npattern_ingester:\n  enabled: false\nquery_range:\n  align_queries_with_step: true\nruler:\n  storage:\n    type: local\n  wal:\n    dir: /var/loki/ruler-wal\nruntime_config:\n  file: /etc/loki/runtime-config/runtime-config.yaml\nschema_config:\n  configs:\n  - from: \"2024-01-01\"\n    index:\n      period: 24h\n      prefix: index_\n    object_store: filesystem\n    schema: v13\n    store: tsdb\nserver:\n  grpc_listen_port: 9095\n  http_listen_port: 3100\n  http_server_read_timeout: 600s\n  http_server_write_timeout: 600s\nstorage_config:\n  bloom_shipper:\n    working_directory: /var/loki/data/bloomshipper\n  boltdb_shipper:\n    index_gateway_client:\n      server_address: \"\"\n  hedging:\n    at: 250ms\n    max_per_second: 20\n    up_to: 3\n  tsdb_shipper:\n    index_gateway_client:\n      server_address: \"\"\n  use_thanos_objstore: false\ntracing:\n  enabled: false\n"},"kind":"ConfigMap","metadata":{"annotations":{"argocd.argoproj.io/tracking-id":"observability-loki:/ConfigMap:observability/loki"},"labels":{"app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki","app.kubernetes.io/version":"3.6.7","helm.sh/chart":"loki-7.0.0"},"name":"loki","namespace":"observability"}}
fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md:278:7:      {"apiVersion":"apps/v1","kind":"StatefulSet","metadata":{"annotations":{"argocd.argoproj.io/tracking-id":"observability-loki:apps/StatefulSet:observability/loki"},"labels":{"app.kubernetes.io/component":"single-binary","app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki","app.kubernetes.io/part-of":"memberlist","app.kubernetes.io/version":"3.6.7","helm.sh/chart":"loki-7.0.0"},"name":"loki","namespace":"observability"},"spec":{"podManagementPolicy":"Parallel","replicas":1,"revisionHistoryLimit":10,"selector":{"matchLabels":{"app.kubernetes.io/component":"single-binary","app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki"}},"serviceName":"loki-headless","template":{"metadata":{"annotations":{"checksum/config":"e19c14ac0dabf912d431bf3d955dc9f342a8d52d9029c6406bba72ff73ffedf5","kubectl.kubernetes.io/default-container":"loki"},"labels":{"app.kubernetes.io/component":"single-binary","app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki","app.kubernetes.io/part-of":"memberlist"}},"spec":{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"single-binary","app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki"}},"topologyKey":"kubernetes.io/hostname"}]}},"automountServiceAccountToken":true,"containers":[{"args":["-config.file=/etc/loki/config/config.yaml","-target=all"],"image":"docker.io/grafana/loki:3.6.7","imagePullPolicy":"IfNotPresent","name":"loki","ports":[{"containerPort":3100,"name":"http-metrics","protocol":"TCP"},{"containerPort":9095,"name":"grpc","protocol":"TCP"},{"containerPort":7946,"name":"http-memberlist","protocol":"TCP"}],"readinessProbe":{"failureThreshold":3,"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":15,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"resources":{"limits":{"memory":"768Mi"},"requests":{"cpu":"100m","memory":"256Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true},"volumeMounts":[{"mountPath":"/tmp","name":"tmp"},{"mountPath":"/etc/loki/config","name":"config"},{"mountPath":"/etc/loki/runtime-config","name":"runtime-config"},{"mountPath":"/rules","name":"sc-rules-volume"}]},{"env":[{"name":"METHOD","value":"WATCH"},{"name":"LABEL","value":"loki_rule"},{"name":"FOLDER","value":"/rules"},{"name":"RESOURCE","value":"both"},{"name":"WATCH_SERVER_TIMEOUT","value":"60"},{"name":"WATCH_CLIENT_TIMEOUT","value":"60"},{"name":"LOG_LEVEL","value":"INFO"}],"image":"docker.io/kiwigrid/k8s-sidecar:2.5.0","imagePullPolicy":"IfNotPresent","name":"loki-sc-rules","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true},"volumeMounts":[{"mountPath":"/tmp","name":"tmp"},{"mountPath":"/rules","name":"sc-rules-volume"}]}],"enableServiceLinks":true,"securityContext":{"fsGroup":10001,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"serviceAccountName":"loki","terminationGracePeriodSeconds":30,"volumes":[{"emptyDir":{},"name":"tmp"},{"configMap":{"items":[{"key":"config.yaml","path":"config.yaml"}],"name":"loki"},"name":"config"},{"configMap":{"name":"loki-runtime"},"name":"runtime-config"},{"emptyDir":{},"name":"sc-rules-volume"}]}},"updateStrategy":{"rollingUpdate":{"partition":0}}}}
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:45:deployment.apps/analytics-service    1/1     1            1           15h   analytics-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb    app.kubernetes.io/name=analytics-service
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:46:deployment.apps/auth-service         2/2     2            2           15h   auth-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb         app.kubernetes.io/name=auth-service
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:47:deployment.apps/evaluation-service   2/2     2            2           15h   evaluation-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb   app.kubernetes.io/name=evaluation-service
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:48:deployment.apps/flag-service         2/2     2            2           15h   flag-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb         app.kubernetes.io/name=flag-service
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:49:deployment.apps/targeting-service    2/2     2            2           15h   targeting-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb    app.kubernetes.io/name=targeting-service
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:120:container=analytics-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:122:env:AWS_SECRET_ACCESS_KEY=
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:127:container=auth-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:133:container=evaluation-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:136:env:AWS_SECRET_ACCESS_KEY=
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:141:container=flag-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:146:container=targeting-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:269:fase4/scripts/34_apply_otel_collector_gitops.sh:366:kubectl kustomize "$OTEL_DIR" > "$TMP/otel-render.yaml"
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:280:fase4/scripts/34_apply_otel_collector_gitops.sh:437:  echo "kubectl kustomize $OTEL_DIR OK"
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:307:fase4/scripts/30_apply_prometheus_grafana_argocd.sh:145:  echo "ERRO: $app não ficou Synced/Healthy dentro do tempo esperado."
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:308:fase4/scripts/30_apply_prometheus_grafana_argocd.sh:162:Este bloco não instala Loki, Promtail, OpenTelemetry Collector, APM externo, incident management, ChatOps ou self-healing.
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:309:fase4/scripts/30_apply_prometheus_grafana_argocd.sh:332:- OpenTelemetry Collector;
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:407:fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:12:Este bloco não instala Loki, Promtail, OpenTelemetry Collector, APM externo, incident management, ChatOps ou self-healing.
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:408:fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:233:  name: observability-opentelemetry-collector
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:409:fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:241:  - chart: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:410:fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:243:      releaseName: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:411:fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:245:      - $values/fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:412:fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:246:    repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:413:fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:555:- OpenTelemetry Collector;
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:423:fase4/docs/evidencias/fase4-bloco34-otel-collector.md:72:kubectl kustomize fase4/gitops/observability/otel-collector OK
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:442:fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md:272:89:      {"apiVersion":"v1","data":{"config.yaml":"\nauth_enabled: false\nbloom_build:\n  builder:\n    planner_address: \"\"\n  enabled: false\nbloom_gateway:\n  client:\n    addresses: \"\"\n  enabled: false\ncommon:\n  compactor_grpc_address: 'loki.observability.svc.cluster.local:9095'\n  path_prefix: /var/loki\n  replication_factor: 1\n  storage:\n    filesystem:\n      chunks_directory: /var/loki/chunks\n      rules_directory: /var/loki/rules\ncompactor:\n  delete_request_store: filesystem\n  retention_enabled: true\nfrontend:\n  scheduler_address: \"\"\n  tail_proxy_url: \"\"\nfrontend_worker:\n  scheduler_address: \"\"\nindex_gateway:\n  mode: simple\nlimits_config:\n  max_cache_freshness_per_query: 10m\n  query_timeout: 300s\n  reject_old_samples: true\n  reject_old_samples_max_age: 168h\n  retention_period: 24h\n  split_queries_by_interval: 15m\n  volume_enabled: true\nmemberlist:\n  join_members:\n  - loki-memberlist.observability.svc.cluster.local\npattern_ingester:\n  enabled: false\nquery_range:\n  align_queries_with_step: true\nruler:\n  storage:\n    type: local\n  wal:\n    dir: /var/loki/ruler-wal\nruntime_config:\n  file: /etc/loki/runtime-config/runtime-config.yaml\nschema_config:\n  configs:\n  - from: \"2024-01-01\"\n    index:\n      period: 24h\n      prefix: index_\n    object_store: filesystem\n    schema: v13\n    store: tsdb\nserver:\n  grpc_listen_port: 9095\n  http_listen_port: 3100\n  http_server_read_timeout: 600s\n  http_server_write_timeout: 600s\nstorage_config:\n  bloom_shipper:\n    working_directory: /var/loki/data/bloomshipper\n  boltdb_shipper:\n    index_gateway_client:\n      server_address: \"\"\n  hedging:\n    at: 250ms\n    max_per_second: 20\n    up_to: 3\n  tsdb_shipper:\n    index_gateway_client:\n      server_address: \"\"\n  use_thanos_objstore: false\ntracing:\n  enabled: false\n"},"kind":"ConfigMap","metadata":{"annotations":{"argocd.argoproj.io/tracking-id":"observability-loki:/ConfigMap:observability/loki"},"labels":{"app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki","app.kubernetes.io/version":"3.6.7","helm.sh/chart":"loki-7.0.0"},"name":"loki","namespace":"observability"}}
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:522:analytics-service-6946467b6b-m7dkk	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:523:auth-service-584688f79d-4fvw5	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:524:auth-service-584688f79d-lkmfd	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:525:evaluation-service-7949b95dd5-6vrk6	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:526:evaluation-service-7949b95dd5-tkxrk	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:527:flag-service-7cd69f6bf9-6sv22	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:528:flag-service-7cd69f6bf9-lvvzs	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:529:targeting-service-66d4bb78b6-ntdtf	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:530:targeting-service-66d4bb78b6-xz4vl	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb 
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md:154:argocd         argocd-application-controller-0                     1/1     Running   0          11h   10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md:155:argocd         argocd-applicationset-controller-5b964db9cd-rl8kn   1/1     Running   0          11h   10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md:156:argocd         argocd-dex-server-b8cc6d795-r658p                   1/1     Running   0          11h   10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md:157:argocd         argocd-notifications-controller-597cccd4ff-q2p2l    1/1     Running   0          11h   10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md:158:argocd         argocd-redis-675f9c4c99-ngqb4                       1/1     Running   0          11h   10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md:159:argocd         argocd-repo-server-5c46694888-b4bqj                 1/1     Running   0          11h   10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md:160:argocd         argocd-server-7f66865588-df8sl                      1/1     Running   0          11h   10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml:5:  namespace: argocd
fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml:7:    argocd.argoproj.io/sync-wave: "10"
fase4/gitops/apps/observability/dashboards-application.yaml:5:  namespace: argocd
fase4/gitops/apps/observability/dashboards-application.yaml:7:    argocd.argoproj.io/sync-wave: "30"
fase4/gitops/apps/observability/loki-application.yaml:5:  namespace: argocd
fase4/gitops/apps/observability/loki-application.yaml:7:    argocd.argoproj.io/sync-wave: "20"
fase4/gitops/apps/observability/promtail-application.yaml:5:  namespace: argocd
fase4/gitops/apps/observability/promtail-application.yaml:7:    argocd.argoproj.io/sync-wave: "21"
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:5:  namespace: argocd
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:7:    argocd.argoproj.io/sync-wave: "30"
fase4/gitops/apps/observability/otel-collector-application.yaml:5:  namespace: argocd
fase4/gitops/apps/observability/kustomization.yaml:1:apiVersion: kustomize.config.k8s.io/v1beta1
fase4/gitops/apps/observability/namespace-application.yaml:5:  namespace: argocd
fase4/gitops/apps/observability/namespace-application.yaml:7:    argocd.argoproj.io/sync-wave: "0"
fase4/gitops/observability/otel-collector/kustomization.yaml:1:apiVersion: kustomize.config.k8s.io/v1beta1
fase4/gitops/observability/namespace/kustomization.yaml:1:apiVersion: kustomize.config.k8s.io/v1beta1
fase4/gitops/observability/dashboards/kustomization.yaml:1:apiVersion: kustomize.config.k8s.io/v1beta1
```

## Análise e recomendação

```text
## Análise técnica

### Serviços e linguagens
- auth-service: Go
- evaluation-service: Go
- analytics-service: Python
- flag-service: Python
- targeting-service: Python

### Sinais de instrumentação atual
- Há algum material relacionado a OpenTelemetry/OTEL no repositório/manifests, mas o inventário anterior mostrou que os Deployments dos serviços ainda não têm variáveis OTEL evidentes.

### Fluxo E2E provável
- evaluation-service recebe chamadas de avaliação de flag.
- flag-service participa do cadastro/consulta de flags.
- targeting-service participa das regras de segmentação.

### Estratégia recomendada para instrumentação
- Priorizar o fluxo de avaliação, porque ele é o caminho funcional mais importante para demonstrar APM.
- Começar pelo evaluation-service, pois é Go e é ponto de entrada do fluxo /evaluate.
- Se evaluation-service chamar flag-service/targeting-service via HTTP, propagar tracecontext nos headers para gerar trace distribuído.
- Instrumentar flag-service e/ou targeting-service em Python depois, para fechar spans multi-serviço.
- Configurar OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector.observability.svc.cluster.local:4318 nos Deployments instrumentados.
- Usar nomes de serviço estáveis: togglemaster-evaluation-service, togglemaster-flag-service, togglemaster-targeting-service.

### Decisão operacional sugerida
- Implementar primeiro instrumentação mínima no evaluation-service e um serviço Python chamado por ele, preferencialmente targeting-service ou flag-service.
- Fazer build/push apenas das imagens alteradas.
- Atualizar GitOps com novas tags e variáveis OTEL.
- Validar traces chegando ao OTel Collector.
- Só depois preparar visual de APM/service map/trace distribuído.

### Figuras futuras
- Figura 7: service map/APM depois que o backend de APM estiver recebendo traces reais.
- Figura 8: trace distribuído de uma chamada /evaluate real com spans encadeados.
```
