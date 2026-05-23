# Fase 4 - BLOCO 35.3 - Snapshot cirúrgico do fluxo de tracing

Data: Sat May 23 06:01:13 PM -03 2026

## Objetivo
Capturar o estado exato dos arquivos que serão alterados para instrumentação OpenTelemetry no fluxo evaluation-service -> flag-service -> targeting-service.

## Arquivos verificados

```text
OK  fase2/src/services/evaluation-service/main.go
OK  fase2/src/services/evaluation-service/handlers.go
OK  fase2/src/services/evaluation-service/evaluator.go
OK  fase2/src/services/evaluation-service/go.mod
OK  fase2/src/services/flag-service/app.py
OK  fase2/src/services/flag-service/requirements.txt
OK  fase2/src/services/targeting-service/app.py
OK  fase2/src/services/targeting-service/requirements.txt
OK  fase3/gitops/base/evaluation-service.yaml
OK  fase3/gitops/base/flag-service.yaml
OK  fase3/gitops/base/targeting-service.yaml
OK  fase3/gitops/base/configmap.yaml
```

## Evaluation-service

```text
### evaluation-service main.go
1:package main
3:import (
26:	HttpClient          *http.Client
31:func main() {
35:	port := os.Getenv("PORT")
108:	httpClient := &http.Client{
124:	mux.HandleFunc("/health", app.healthHandler)
125:	mux.HandleFunc("/evaluate", app.evaluationHandler)
128:	if err := http.ListenAndServe(":"+port, mux); err != nil {

### evaluation-service handlers.go
10:	FlagName string `json:"flag_name"`
15:func (a *App) healthHandler(w http.ResponseWriter, r *http.Request) {
17:	w.WriteHeader(http.StatusOK)
18:	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
21:func (a *App) evaluationHandler(w http.ResponseWriter, r *http.Request) {
26:	flagName := r.URL.Query().Get("flag_name")
28:	if userID == "" || flagName == "" {
29:		http.Error(w, `{"error": "user_id e flag_name são obrigatórios"}`, http.StatusBadRequest)
34:	result, err := a.getDecision(userID, flagName)
41:			log.Printf("Erro ao avaliar flag '%s': %v", flagName, err)
42:			http.Error(w, `{"error": "Erro interno ao avaliar a flag"}`, http.StatusBadGateway)
49:	go a.sendEvaluationEvent(userID, flagName, result)
52:	w.WriteHeader(http.StatusOK)
53:	json.NewEncoder(w).Encode(EvaluationResponse{
54:		FlagName: flagName,

### evaluation-service evaluator.go
22:func (a *App) getDecision(userID, flagName string) (bool, error) {
23:	// 1. Obter os dados da flag (do cache ou dos serviços)
24:	info, err := a.getCombinedFlagInfo(flagName)
34:func (a *App) getCombinedFlagInfo(flagName string) (*CombinedFlagInfo, error) {
35:	cacheKey := fmt.Sprintf("flag_info:%s", flagName)
43:			log.Printf("Cache HIT para flag '%s'", flagName)
47:		log.Printf("Erro ao desserializar cache para flag '%s': %v", flagName, err)
50:	log.Printf("Cache MISS para flag '%s'", flagName)
52:	info, err := a.fetchFromServices(flagName)
66:// fetchFromServices busca dados do flag-service e targeting-service concorrentemente
67:func (a *App) fetchFromServices(flagName string) (*CombinedFlagInfo, error) {
71:	var flagInfo *Flag
73:	var flagErr, ruleErr error
75:	// Goroutine 1: Buscar do flag-service
78:		flagInfo, flagErr = a.fetchFlag(flagName)
81:	// Goroutine 2: Buscar do targeting-service
84:		ruleInfo, ruleErr = a.fetchRule(flagName)
89:	if flagErr != nil {
90:		return nil, flagErr
93:		log.Printf("Aviso: Nenhuma regra de segmentação encontrada para '%s'. Usando padrão.", flagName)
97:		Flag: flagInfo,
103:func (a *App) fetchFlag(flagName string) (*Flag, error) {
104:	url := fmt.Sprintf("%s/flags/%s", a.FlagServiceURL, flagName)
106:	apiKey := os.Getenv("SERVICE_API_KEY")
107:	req, _ := http.NewRequest("GET", url, nil)
108:	req.Header.Set("Authorization", "Bearer "+apiKey)
110:	resp, err := a.HttpClient.Do(req)
112:		return nil, fmt.Errorf("erro ao chamar flag-service: %w", err)
116:	if resp.StatusCode == http.StatusNotFound {
117:		return nil, &NotFoundError{flagName}
119:	if resp.StatusCode != http.StatusOK {
120:		return nil, fmt.Errorf("flag-service retornou status %d", resp.StatusCode)
124:	var flag Flag
125:	if err := json.Unmarshal(body, &flag); err != nil {
126:		return nil, fmt.Errorf("erro ao desserializar resposta do flag-service: %w", err)
128:	return &flag, nil
131:func (a *App) fetchRule(flagName string) (*TargetingRule, error) {
132:	url := fmt.Sprintf("%s/rules/%s", a.TargetingServiceURL, flagName)
133:	apiKey := os.Getenv("SERVICE_API_KEY") // Usa a mesma chave
134:	req, _ := http.NewRequest("GET", url, nil)
135:	req.Header.Set("Authorization", "Bearer "+apiKey)
137:	resp, err := a.HttpClient.Do(req)
139:		return nil, fmt.Errorf("erro ao chamar targeting-service: %w", err)
143:	if resp.StatusCode == http.StatusNotFound {
144:		return nil, &NotFoundError{flagName} // Não é um erro fatal
146:	if resp.StatusCode != http.StatusOK {
147:		return nil, fmt.Errorf("targeting-service retornou status %d", resp.StatusCode)
153:		return nil, fmt.Errorf("erro ao desserializar resposta do targeting-service: %w", err)
159:func (a *App) runEvaluationLogic(info *CombinedFlagInfo, userID string) bool {
174:			log.Printf("Erro: valor da regra de porcentagem não é um número para a flag '%s'", info.Flag.Name)
189:func getDeterministicBucket(input string) int {
```

## Flag-service

```text
### flag-service app.py
3:import psycopg2
4:import requests
5:from psycopg2.extras import RealDictCursor
6:from psycopg2.pool import SimpleConnectionPool
7:from flask import Flask, request, jsonify
19:app = Flask(__name__)
23:AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL")
25:if not DATABASE_URL or not AUTH_SERVICE_URL:
26:    log.critical("Erro: DATABASE_URL e AUTH_SERVICE_URL devem ser definidos.")
34:except psycopg2.OperationalError as e:
39:def require_auth(f):
42:    def decorated(*args, **kwargs):
43:        auth_header = request.headers.get("Authorization")
45:            return jsonify({"error": "Authorization header obrigatório"}), 401
48:            # Chama o /validate do auth-service
49:            validate_url = f"{AUTH_SERVICE_URL}/validate"
50:            response = requests.get(validate_url, headers={"Authorization": auth_header}, timeout=3)
54:                return jsonify({"error": "Chave de API inválida"}), 401
56:        except requests.exceptions.Timeout:
58:            return jsonify({"error": "Serviço de autenticação indisponível (timeout)"}), 504 # Gateway Timeout
59:        except requests.exceptions.RequestException as e:
61:            return jsonify({"error": "Serviço de autenticação indisponível"}), 503 # Service Unavailable
69:@app.route('/health')
70:def health():
71:    return jsonify({"status": "ok"})
73:@app.route('/flags', methods=['POST'])
75:def create_flag():
79:        return jsonify({"error": "'name' é obrigatório"}), 400
98:        return jsonify(new_flag), 201
99:    except psycopg2.IntegrityError:
102:        return jsonify({"error": f"Flag '{name}' já existe"}), 409
106:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500
111:@app.route('/flags', methods=['GET'])
113:def get_flags():
122:        return jsonify(flags)
125:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500
130:@app.route('/flags/<string:name>', methods=['GET'])
132:def get_flag(name):
142:            return jsonify({"error": "Flag não encontrada"}), 404
143:        return jsonify(flag)
146:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500
151:@app.route('/flags/<string:name>', methods=['PUT'])
153:def update_flag(name):
157:        return jsonify({"error": "Corpo da requisição obrigatório"}), 400
171:        return jsonify({"error": "Pelo menos um campo ('description', 'is_enabled') é obrigatório"}), 400
185:            return jsonify({"error": "Flag não encontrada"}), 404
190:        return jsonify(updated_flag), 200
194:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500
199:@app.route('/flags/<string:name>', methods=['DELETE'])
201:def delete_flag(name):
211:            return jsonify({"error": "Flag não encontrada"}), 404
219:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500

### flag-service requirements.txt
Flask==2.2.2
psycopg2-binary==2.9.5
gunicorn==20.1.0
python-dotenv==0.21.0
requests==2.28.1
Werkzeug==2.3.8
```

## Targeting-service

```text
### targeting-service app.py
3:import psycopg2
4:import requests
6:from psycopg2.extras import RealDictCursor, Json
7:from psycopg2.pool import SimpleConnectionPool
8:from flask import Flask, request, jsonify
20:app = Flask(__name__)
24:AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL")
26:if not DATABASE_URL or not AUTH_SERVICE_URL:
27:    log.critical("Erro: DATABASE_URL e AUTH_SERVICE_URL devem ser definidos.")
34:except psycopg2.OperationalError as e:
39:def require_auth(f):
42:    def decorated(*args, **kwargs):
43:        auth_header = request.headers.get("Authorization")
45:            return jsonify({"error": "Authorization header obrigatório"}), 401
48:            validate_url = f"{AUTH_SERVICE_URL}/validate"
49:            response = requests.get(validate_url, headers={"Authorization": auth_header}, timeout=3)
53:                return jsonify({"error": "Chave de API inválida"}), 401
55:        except requests.exceptions.Timeout:
57:            return jsonify({"error": "Serviço de autenticação indisponível (timeout)"}), 504 # Gateway Timeout
58:        except requests.exceptions.RequestException as e:
60:            return jsonify({"error": "Serviço de autenticação indisponível"}), 503 # Service Unavailable
67:@app.route('/health')
68:def health():
69:    return jsonify({"status": "ok"})
71:@app.route('/rules', methods=['POST'])
73:def create_rule():
77:        return jsonify({"error": "'flag_name' e 'rules' (JSON) são obrigatórios"}), 400
96:        return jsonify(new_rule), 201
97:    except psycopg2.IntegrityError:
100:        return jsonify({"error": f"Regra para a flag '{flag_name}' já existe"}), 409
104:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500
109:@app.route('/rules/<string:flag_name>', methods=['GET'])
111:def get_rule(flag_name):
121:            return jsonify({"error": "Regra não encontrada"}), 404
122:        return jsonify(rule)
125:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500
130:@app.route('/rules/<string:flag_name>', methods=['PUT'])
132:def update_rule(flag_name):
136:        return jsonify({"error": "Corpo da requisição obrigatório"}), 400
149:        return jsonify({"error": "Pelo menos um campo ('rules', 'is_enabled') é obrigatório"}), 400
163:            return jsonify({"error": "Regra não encontrada"}), 404
168:        return jsonify(updated_rule), 200
172:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500
177:@app.route('/rules/<string:flag_name>', methods=['DELETE'])
179:def delete_rule(flag_name):
189:            return jsonify({"error": "Regra não encontrada"}), 404
197:        return jsonify({"error": "Erro interno do servidor", "details": str(e)}), 500

### targeting-service requirements.txt
Flask==2.2.2
psycopg2-binary==2.9.5
gunicorn==20.1.0
python-dotenv==0.21.0
requests==2.28.1
Werkzeug==2.3.8
```

## GitOps atual

```text
### configmap
4:  name: togglemaster-runtime-config
7:    app.kubernetes.io/name: togglemaster
11:  AUTH_SERVICE_URL: http://auth-service:8000
12:  FLAG_SERVICE_URL: http://flag-service:8000
13:  TARGETING_SERVICE_URL: http://targeting-service:8000
14:  REDIS_PORT: "6379"
15:  REDIS_URL: redis://togglemaster-dev-redis.hmdfss.ng.0001.use1.cache.amazonaws.com:6379
16:  AWS_REGION: us-east-1
17:  AWS_SQS_URL: https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events
18:  AWS_DYNAMODB_TABLE: togglemaster-dev-ToggleMasterAnalytics

### evaluation-service.yaml
2:kind: Deployment
4:  name: evaluation-service
7:    app.kubernetes.io/name: evaluation-service
18:      app.kubernetes.io/name: evaluation-service
22:        app.kubernetes.io/name: evaluation-service
26:        - name: evaluation-service
27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
30:            - containerPort: 8000
31:          envFrom:
33:                name: togglemaster-runtime-config
34:          env:
35:            - name: SERVICE_API_KEY
38:                  name: togglemaster-runtime-secret
40:            - name: AWS_ACCESS_KEY_ID
43:                  name: togglemaster-runtime-secret
45:            - name: AWS_SECRET_ACCESS_KEY
48:                  name: togglemaster-runtime-secret
50:            - name: AWS_SESSION_TOKEN
53:                  name: togglemaster-runtime-secret
55:          readinessProbe:
61:          livenessProbe:
71:  name: evaluation-service
75:    app.kubernetes.io/name: evaluation-service
77:    - name: http

### flag-service.yaml
2:kind: Deployment
4:  name: flag-service
7:    app.kubernetes.io/name: flag-service
18:      app.kubernetes.io/name: flag-service
22:        app.kubernetes.io/name: flag-service
26:        - name: flag-service
27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
30:            - containerPort: 8000
31:          envFrom:
33:                name: togglemaster-runtime-config
34:          env:
35:            - name: DATABASE_URL
38:                  name: togglemaster-runtime-secret
40:          readinessProbe:
46:          livenessProbe:
56:  name: flag-service
60:    app.kubernetes.io/name: flag-service
62:    - name: http

### targeting-service.yaml
2:kind: Deployment
4:  name: targeting-service
7:    app.kubernetes.io/name: targeting-service
18:      app.kubernetes.io/name: targeting-service
22:        app.kubernetes.io/name: targeting-service
26:        - name: targeting-service
27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
30:            - containerPort: 8000
31:          envFrom:
33:                name: togglemaster-runtime-config
34:          env:
35:            - name: DATABASE_URL
38:                  name: togglemaster-runtime-secret
40:          readinessProbe:
46:          livenessProbe:
56:  name: targeting-service
60:    app.kubernetes.io/name: targeting-service
62:    - name: http
```

## Decisão de continuidade
O próximo bloco poderá aplicar patches mínimos e controlados de OpenTelemetry nos serviços do fluxo de avaliação.
