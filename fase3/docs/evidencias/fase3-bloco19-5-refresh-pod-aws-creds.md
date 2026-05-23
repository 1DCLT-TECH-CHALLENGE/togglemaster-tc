# Fase 3 - BLOCO 19.5 - Atualização das Credenciais AWS dos Pods

Data: Sat May 23 02:11:50 PM -03 2026

## Objetivo

Corrigir a falha `ExpiredToken` observada nos pods `evaluation-service` e `analytics-service`.

Este bloco atualiza apenas as chaves AWS temporárias no Kubernetes Secret operacional `togglemaster-runtime-secret`, sem exibir valores sensíveis, e reinicia somente os deployments afetados:

- `evaluation-service`
- `analytics-service`

Nenhum recurso AWS, Terraform, GitOps ou manifest versionado é alterado.


## 1. Pré-checks


### AWS identity atual da VM

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

### ArgoCD antes

```bash
$ kubectl get application togglemaster-dev -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         c597af16d98f2bc0937d4e165966971f66fd6c47   default

```

RC: `0`

### Pods antes

```bash
$ kubectl get pods -n togglemaster -o wide
NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-79df69b56d-q85sh    1/1     Running   0          16m   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
auth-service-584688f79d-vpg2z         1/1     Running   0          10h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
auth-service-584688f79d-xt6v8         1/1     Running   0          10h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
evaluation-service-54756c5b77-bm28v   1/1     Running   0          16m   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
evaluation-service-54756c5b77-h4qrs   1/1     Running   0          15m   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-9ffxm         1/1     Running   0          10h   10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-x7pxc         1/1     Running   0          10h   10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-7zc9d    1/1     Running   0          10h   10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-8tw7t    1/1     Running   0          10h   10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>

```

RC: `0`

## 2. Obter credenciais AWS atuais sem imprimir valores

- OK: credenciais AWS atuais carregadas em memória sem exibir valores.

## 3. Atualizar somente campos AWS no Kubernetes Secret

- OK: Secret `togglemaster-runtime-secret` atualizado somente nos campos AWS.

## 4. Reiniciar somente evaluation-service e analytics-service


### Rollout restart evaluation-service

```bash
$ kubectl -n togglemaster rollout restart deployment/evaluation-service
deployment.apps/evaluation-service restarted

```

RC: `0`

### Rollout restart analytics-service

```bash
$ kubectl -n togglemaster rollout restart deployment/analytics-service
deployment.apps/analytics-service restarted

```

RC: `0`

### Aguardar rollout evaluation-service

```bash
$ kubectl -n togglemaster rollout status deployment/evaluation-service --timeout=180s
Waiting for deployment "evaluation-service" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "evaluation-service" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "evaluation-service" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "evaluation-service" rollout to finish: 1 of 2 updated replicas are available...
deployment "evaluation-service" successfully rolled out

```

RC: `0`

### Aguardar rollout analytics-service

```bash
$ kubectl -n togglemaster rollout status deployment/analytics-service --timeout=180s
deployment "analytics-service" successfully rolled out

```

RC: `0`

## 5. Estado após restart


### Pods após restart

```bash
$ kubectl get pods -n togglemaster -o wide
NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-6946467b6b-9fvmm    1/1     Running   0          97s   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
auth-service-584688f79d-vpg2z         1/1     Running   0          10h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
auth-service-584688f79d-xt6v8         1/1     Running   0          10h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
evaluation-service-7949b95dd5-kf2md   1/1     Running   0          98s   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
evaluation-service-7949b95dd5-wbrlc   1/1     Running   0          54s   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-9ffxm         1/1     Running   0          10h   10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-x7pxc         1/1     Running   0          10h   10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-7zc9d    1/1     Running   0          10h   10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-8tw7t    1/1     Running   0          10h   10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>

```

RC: `0`

### ArgoCD após restart

```bash
$ kubectl get application togglemaster-dev -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         c597af16d98f2bc0937d4e165966971f66fd6c47   default

```

RC: `0`

## 6. Logs recentes após atualização de credenciais


### Logs evaluation-service após restart

```bash
$ kubectl logs -n togglemaster deployment/evaluation-service --tail=80
Found 2 pods, using pod/evaluation-service-7949b95dd5-kf2md
2026/05/23 17:12:31 Conectado ao Redis com sucesso!
2026/05/23 17:12:31 Cliente SQS inicializado com sucesso.
2026/05/23 17:12:31 Serviço de Avaliação (Go) rodando na porta 8000

```

RC: `0`

### Logs analytics-service após restart

```bash
$ kubectl logs -n togglemaster deployment/analytics-service --tail=100
[2026-05-23 17:12:41 +0000] [1] [INFO] Starting gunicorn 20.1.0
[2026-05-23 17:12:41 +0000] [1] [INFO] Listening at: http://0.0.0.0:8000 (1)
[2026-05-23 17:12:41 +0000] [1] [INFO] Using worker: sync
[2026-05-23 17:12:41 +0000] [7] [INFO] Booting worker with pid: 7
2026-05-23 17:12:41,853 - INFO - Found credentials in environment variables.
2026-05-23 17:12:41,939 - INFO - Clientes Boto3 inicializados na região us-east-1
2026-05-23 17:12:41,941 - INFO - Iniciando o worker SQS...

```

RC: `0`

## 7. Resultado


## Resultado

- ArgoCD: `Synced/Healthy`
- Pods no namespace `togglemaster`: sem pods não prontos.
- Log completo: `/home/wellk/togglemaster-tc/fase3/logs/fase3-bloco19-5-refresh-pod-aws-creds.log`
