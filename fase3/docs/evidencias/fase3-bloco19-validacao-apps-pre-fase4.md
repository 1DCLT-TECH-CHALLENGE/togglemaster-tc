# Fase 3 - BLOCO 19 - Validação Funcional das Aplicações Pré-Fase 4

Data: Sat May 23 02:19:40 PM -03 2026

## Objetivo

Validar que as aplicações da Fase 3 continuam funcionais na AWS antes de iniciar a Fase 4.

Este bloco valida:

- Health dos 5 microsserviços.
- Criação e validação de API key.
- Flag service.
- Targeting service.
- Evaluation service.
- Envio de eventos para SQS real.
- Consumo pelo analytics-service.
- Gravação no DynamoDB real.
- Estado final dos pods e ArgoCD.

## Observação

Este teste usa `kubectl port-forward` local para acessar os Services `ClusterIP`, sem criar ou alterar recursos de infraestrutura.


## 1. Pré-checks AWS, Kubernetes e GitOps


### AWS identity

```bash
$ aws sts get-caller-identity --output table
------------------------------------------------------------------------------------------------
|                                       GetCallerIdentity                                      |
+---------+------------------------------------------------------------------------------------+
|  Account|  590183666984                                                                      |
|  Arn    |  arn:aws:sts::590183666984:assumed-role/voclabs/user4447841=wellk.well@gmail.com   |
|  UserId |  AROAYS2NQCUUFEE2UOXGE:user4447841=wellk.well@gmail.com                            |
+---------+------------------------------------------------------------------------------------+
```

RC: `0`

### Contexto kubectl

```bash
$ kubectl config current-context
togglemaster-dev-eks
```

RC: `0`

### ArgoCD application

```bash
$ kubectl get application togglemaster-dev -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         c597af16d98f2bc0937d4e165966971f66fd6c47   default
```

RC: `0`

### Pods iniciais

```bash
$ kubectl get pods -n togglemaster -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-6946467b6b-9fvmm    1/1     Running   0          7m45s   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
auth-service-584688f79d-vpg2z         1/1     Running   0          10h     10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
auth-service-584688f79d-xt6v8         1/1     Running   0          10h     10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
evaluation-service-7949b95dd5-kf2md   1/1     Running   0          7m46s   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
evaluation-service-7949b95dd5-wbrlc   1/1     Running   0          7m2s    10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-9ffxm         1/1     Running   0          10h     10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-x7pxc         1/1     Running   0          10h     10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-7zc9d    1/1     Running   0          10h     10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-8tw7t    1/1     Running   0          10h     10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>
```

RC: `0`

### Services

```bash
$ kubectl get svc -n togglemaster -o wide
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
analytics-service    ClusterIP   172.20.81.122   <none>        8000/TCP   12h   app.kubernetes.io/name=analytics-service
auth-service         ClusterIP   172.20.222.48   <none>        8000/TCP   12h   app.kubernetes.io/name=auth-service
evaluation-service   ClusterIP   172.20.66.90    <none>        8000/TCP   12h   app.kubernetes.io/name=evaluation-service
flag-service         ClusterIP   172.20.51.154   <none>        8000/TCP   12h   app.kubernetes.io/name=flag-service
targeting-service    ClusterIP   172.20.90.181   <none>        8000/TCP   12h   app.kubernetes.io/name=targeting-service
```

RC: `0`

## 2. Validar Secret operacional sem expor valores

- OK: Secret operacional existe e MASTER_KEY foi carregada sem exibir valor.

## 3. Descobrir SQS e contar DynamoDB antes do teste

- SQS URL validada: `https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events`
- DynamoDB Count antes do teste: `4`

## 4. Iniciar port-forwards locais


## 5. Health checks HTTP dos microsserviços


### Health auth-service

- HTTP status: `200`

```json
{"status": "ok"}

```

### Health flag-service

- HTTP status: `200`

```json
{"status": "ok"}

```

### Health targeting-service

- HTTP status: `200`

```json
{"status": "ok"}

```

### Health evaluation-service

- HTTP status: `200`

```json
{"status": "ok"}

```

### Health analytics-service

- HTTP status: `200`

```json
{"status": "ok"}

```

## 6. Auth-service: criar e validar API key


### Auth - criar API key

- HTTP status: `201`

```json
{"name": "phase3-pre-fase4", "key": "REDACTED", "message": "Guarde esta chave com segurança! Você não poderá vê-la novamente."}

```
- OK: API key criada e carregada sem exibir valor.

### Auth - validar API key

- HTTP status: `200`

```json
{"message": "Chave válida"}

```

## 7. Flag-service: criar/listar flag


### Flag - criar flag enable-new-dashboard

- HTTP status: `409`

```json
{"error": "Flag 'enable-new-dashboard' já existe"}

```

### Flag - listar flags

- HTTP status: `200`

```json
[{"created_at": "Sat, 23 May 2026 05:15:59 GMT", "description": "Flag E2E cloud Fase 3", "id": 1, "is_enabled": true, "name": "enable-new-dashboard", "updated_at": "Sat, 23 May 2026 05:15:59 GMT"}]

```

## 8. Targeting-service: criar regra


### Targeting - criar regra PERCENTAGE 50

- HTTP status: `409`

```json
{"error": "Regra para a flag 'enable-new-dashboard' já existe"}

```

## 9. Evaluation-service: avaliar flag e gerar eventos


### Evaluation GET - user-123

- HTTP status: `200`

```json
{"flag_name": "enable-new-dashboard", "user_id": "user-123", "result": true}

```

### Evaluation GET - user-abc

- HTTP status: `200`

```json
{"flag_name": "enable-new-dashboard", "user_id": "user-abc", "result": false}

```

### Evaluation GET - user-123-sqs

- HTTP status: `200`

```json
{"flag_name": "enable-new-dashboard", "user_id": "user-123-sqs", "result": true}

```

## 10. Validar SQS, analytics-service e DynamoDB


### Atributos SQS após avaliações

```json
{
    "Attributes": {
        "ApproximateNumberOfMessages": "0",
        "ApproximateNumberOfMessagesNotVisible": "0",
        "ApproximateNumberOfMessagesDelayed": "0"
    }
}

```
- DynamoDB Count depois do teste: `7`

### Amostra DynamoDB após teste

```json
{
    "Items": [
        {
            "event_id": {
                "S": "6231ce61-089d-4138-8517-38c566644f36"
            },
            "result": {
                "BOOL": true
            },
            "user_id": {
                "S": "user-123-sqs"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-23T05:16:02.320027098Z"
            }
        },
        {
            "event_id": {
                "S": "43f7a5fc-d2bd-45dc-9a5f-efe4a04af24f"
            },
            "result": {
                "BOOL": true
            },
            "user_id": {
                "S": "user-123"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-23T05:16:01.490741194Z"
            }
        },
        {
            "event_id": {
                "S": "939834bd-fde2-4fc6-a777-a0efe4ccf649"
            },
            "result": {
                "BOOL": true
            },
            "user_id": {
                "S": "user-123"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-23T17:20:08.49283359Z"
            }
        },
        {
            "event_id": {
                "S": "21d12374-1e2f-4a18-92bb-25a663bbdc82"
            },
            "result": {
                "BOOL": true
            },
            "user_id": {
                "S": "synthetic-phase3-bloco19-4-20260523134512"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-23T16:45:12Z"
            }
        },
        {
            "event_id": {
                "S": "dc30b9b9-044e-44d0-8e3f-c14e048d840a"
            },
            "result": {
                "BOOL": true
            },
            "user_id": {
                "S": "user-123-sqs"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-23T17:20:09.628981331Z"
            }
        }
    ],
    "Count": 5,
    "ScannedCount": 5,
    "LastEvaluatedKey": {
        "event_id": {
            "S": "dc30b9b9-044e-44d0-8e3f-c14e048d840a"
        }
    }
}

```

## 11. Logs recentes dos serviços


### Logs evaluation-service

```bash
$ kubectl logs -n togglemaster deployment/evaluation-service --tail=80
Found 2 pods, using pod/evaluation-service-7949b95dd5-kf2md
2026/05/23 17:12:31 Conectado ao Redis com sucesso!
2026/05/23 17:12:31 Cliente SQS inicializado com sucesso.
2026/05/23 17:12:31 Serviço de Avaliação (Go) rodando na porta 8000
2026/05/23 17:20:08 Cache MISS para flag 'enable-new-dashboard'
2026/05/23 17:20:08 Evento de avaliação enviado para SQS (Flag: enable-new-dashboard)
2026/05/23 17:20:09 Cache HIT para flag 'enable-new-dashboard'
2026/05/23 17:20:09 Evento de avaliação enviado para SQS (Flag: enable-new-dashboard)
2026/05/23 17:20:09 Cache HIT para flag 'enable-new-dashboard'
2026/05/23 17:20:09 Evento de avaliação enviado para SQS (Flag: enable-new-dashboard)
```

RC: `0`

### Logs analytics-service

```bash
$ kubectl logs -n togglemaster deployment/analytics-service --tail=120
[2026-05-23 17:12:41 +0000] [1] [INFO] Starting gunicorn 20.1.0
[2026-05-23 17:12:41 +0000] [1] [INFO] Listening at: http://0.0.0.0:8000 (1)
[2026-05-23 17:12:41 +0000] [1] [INFO] Using worker: sync
[2026-05-23 17:12:41 +0000] [7] [INFO] Booting worker with pid: 7
2026-05-23 17:12:41,853 - INFO - Found credentials in environment variables.
2026-05-23 17:12:41,939 - INFO - Clientes Boto3 inicializados na região us-east-1
2026-05-23 17:12:41,941 - INFO - Iniciando o worker SQS...
2026-05-23 17:20:08,596 - INFO - Recebidas 1 mensagens.
2026-05-23 17:20:08,597 - INFO - Processando mensagem ID: 0f6a7118-d1f8-4926-8166-fe6a8fdcd8c3
2026-05-23 17:20:08,651 - INFO - Evento 939834bd-fde2-4fc6-a777-a0efe4ccf649 (Flag: enable-new-dashboard) salvo no DynamoDB.
2026-05-23 17:20:09,093 - INFO - Recebidas 1 mensagens.
2026-05-23 17:20:09,093 - INFO - Processando mensagem ID: c612f11a-c58a-4604-8ff7-a9e6f49ed8e2
2026-05-23 17:20:09,103 - INFO - Evento 9859d240-7e65-4ed0-9fb2-038ae3a22995 (Flag: enable-new-dashboard) salvo no DynamoDB.
2026-05-23 17:20:09,744 - INFO - Recebidas 1 mensagens.
2026-05-23 17:20:09,744 - INFO - Processando mensagem ID: 0e4d5310-7098-4b97-881b-e591bc24b1f9
2026-05-23 17:20:09,752 - INFO - Evento dc30b9b9-044e-44d0-8e3f-c14e048d840a (Flag: enable-new-dashboard) salvo no DynamoDB.
```

RC: `0`

## 12. Estado final


### ArgoCD final

```bash
$ kubectl get application togglemaster-dev -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         c597af16d98f2bc0937d4e165966971f66fd6c47   default
```

RC: `0`

### Pods finais

```bash
$ kubectl get pods -n togglemaster -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-6946467b6b-9fvmm    1/1     Running   0          8m38s   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
auth-service-584688f79d-vpg2z         1/1     Running   0          10h     10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
auth-service-584688f79d-xt6v8         1/1     Running   0          10h     10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
evaluation-service-7949b95dd5-kf2md   1/1     Running   0          8m39s   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
evaluation-service-7949b95dd5-wbrlc   1/1     Running   0          7m55s   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-9ffxm         1/1     Running   0          10h     10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-x7pxc         1/1     Running   0          10h     10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-7zc9d    1/1     Running   0          10h     10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-8tw7t    1/1     Running   0          10h     10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>
```

RC: `0`

## Resultado final

- ArgoCD final: `Synced/Healthy`
- DynamoDB antes: `4`
- DynamoDB depois: `7`
- Log completo: `/home/wellk/togglemaster-tc/fase3/logs/fase3-bloco19-validacao-apps-pre-fase4.log`
