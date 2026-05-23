# Fase 3 - BLOCO 19.4 - Diagnóstico do Fluxo Assíncrono

Data: Sat May 23 01:45:02 PM -03 2026

## Objetivo

Diagnosticar a falha isolada no trecho assíncrono da validação funcional da Fase 3:

`evaluation-service -> SQS -> analytics-service -> DynamoDB`.

Este bloco não cria infraestrutura e não altera manifests. Ele apenas coleta estado, envia uma mensagem sintética controlada para SQS e valida se o analytics-service grava no DynamoDB.


## 1. Pré-checks


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

### ArgoCD

```bash
$ kubectl get application togglemaster-dev -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         c597af16d98f2bc0937d4e165966971f66fd6c47   default

```

RC: `0`

### Pods

```bash
$ kubectl get pods -n togglemaster -o wide
NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-7cbdb57c5-8hr2t     1/1     Running   0          10h   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
auth-service-584688f79d-vpg2z         1/1     Running   0          10h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
auth-service-584688f79d-xt6v8         1/1     Running   0          10h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
evaluation-service-6658f5d98c-77lkz   1/1     Running   0          10h   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
evaluation-service-6658f5d98c-7vhkf   1/1     Running   0          10h   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-9ffxm         1/1     Running   0          10h   10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-x7pxc         1/1     Running   0          10h   10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-7zc9d    1/1     Running   0          10h   10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-8tw7t    1/1     Running   0          10h   10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>

```

RC: `0`

### Deployments

```bash
$ kubectl get deployments -n togglemaster -o wide
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS           IMAGES                                                                                     SELECTOR
analytics-service    1/1     1            1           12h   analytics-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb    app.kubernetes.io/name=analytics-service
auth-service         2/2     2            2           12h   auth-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb         app.kubernetes.io/name=auth-service
evaluation-service   2/2     2            2           12h   evaluation-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb   app.kubernetes.io/name=evaluation-service
flag-service         2/2     2            2           12h   flag-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb         app.kubernetes.io/name=flag-service
targeting-service    2/2     2            2           12h   targeting-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb    app.kubernetes.io/name=targeting-service

```

RC: `0`

## 2. Recursos SQS e DynamoDB

- SQS URL: `https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events`

### Atributos SQS antes

```bash
$ aws sqs get-queue-attributes --region us-east-1 --queue-url https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible ApproximateNumberOfMessagesDelayed
{
    "Attributes": {
        "ApproximateNumberOfMessages": "0",
        "ApproximateNumberOfMessagesNotVisible": "0",
        "ApproximateNumberOfMessagesDelayed": "0"
    }
}

```

RC: `0`
- DynamoDB Count antes: `3`

## 3. Logs recentes antes da mensagem sintética


### Logs evaluation-service antes

```bash
$ kubectl logs -n togglemaster deployment/evaluation-service --tail=120
Found 2 pods, using pod/evaluation-service-6658f5d98c-77lkz
2026/05/23 06:24:13 Conectado ao Redis com sucesso!
2026/05/23 06:24:13 Cliente SQS inicializado com sucesso.
2026/05/23 06:24:13 Serviço de Avaliação (Go) rodando na porta 8000
2026/05/23 16:43:17 Cache MISS para flag 'enable-new-dashboard'
2026/05/23 16:43:18 Erro ao enviar mensagem para SQS: ExpiredToken: The security token included in the request is expired
	status code: 403, request id: d78c5362-a8c1-523f-8609-31e973a76dbe
2026/05/23 16:43:18 Cache HIT para flag 'enable-new-dashboard'
2026/05/23 16:43:18 Erro ao enviar mensagem para SQS: ExpiredToken: The security token included in the request is expired
	status code: 403, request id: 71025be0-4b53-55cb-8af2-396b9035d06c
2026/05/23 16:43:18 Cache HIT para flag 'enable-new-dashboard'
2026/05/23 16:43:19 Erro ao enviar mensagem para SQS: ExpiredToken: The security token included in the request is expired
	status code: 403, request id: 0d4e6546-2020-5e30-8e0c-07cdfb47faa2

```

RC: `0`

### Logs analytics-service antes

```bash
$ kubectl logs -n togglemaster deployment/analytics-service --tail=160
2026-05-23 16:18:30,356 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:18:40,384 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:18:50,413 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:00,440 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:10,469 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:20,496 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:30,521 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:40,549 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:50,576 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:00,601 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:10,627 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:20,657 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:30,686 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:40,712 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:50,751 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:00,777 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:10,813 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:20,840 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:30,868 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:40,901 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:50,930 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:00,956 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:10,985 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:21,014 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:31,046 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:41,072 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:51,100 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:01,130 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:11,156 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:21,183 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:31,213 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:41,241 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:51,277 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:01,325 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:11,352 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:21,377 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:31,403 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:41,430 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:51,460 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:01,499 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:11,529 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:21,557 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:31,593 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:41,619 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:51,648 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:01,691 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:11,718 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:21,752 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:31,782 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:41,810 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:51,844 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:02,065 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:12,093 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:22,127 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:32,156 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:42,188 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:52,215 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:02,266 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:12,304 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:22,330 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:32,369 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:42,400 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:52,429 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:02,471 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:12,509 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:22,537 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:32,562 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:42,591 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:52,618 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:02,783 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:12,810 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:22,840 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:32,865 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:42,889 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:52,916 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:02,943 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:12,972 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:22,996 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:33,033 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:43,064 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:53,089 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:03,116 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:13,143 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:23,171 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:33,250 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:43,278 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:53,306 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:03,338 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:13,373 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:23,401 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:33,428 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:43,466 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:53,496 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:03,523 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:13,552 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:23,582 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:33,607 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:43,638 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:53,668 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:03,703 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:13,734 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:23,761 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:33,787 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:43,815 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:53,845 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:03,879 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:13,907 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:23,933 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:33,959 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:43,987 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:54,021 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:04,048 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:14,079 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:24,106 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:34,134 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:44,161 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:54,191 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:04,222 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:14,251 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:24,285 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:34,313 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:44,351 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:54,378 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:04,419 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:14,446 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:24,472 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:34,498 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:44,525 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:54,550 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:04,580 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:14,609 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:24,644 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:34,679 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:44,709 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:54,739 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:04,768 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:14,795 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:24,823 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:34,849 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:44,884 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:54,910 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:04,950 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:14,980 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:25,015 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:35,042 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:45,067 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:55,095 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:05,123 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:15,148 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:25,196 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:35,226 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:45,253 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:55,281 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:05,312 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:15,359 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:25,386 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:35,451 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:45,479 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:55,508 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:45:05,548 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired

```

RC: `0`

## 4. Inspeção local do código para schema de SQS/DynamoDB


### Grep local de funções SQS/DynamoDB

```bash
fase2/docker/.env.phase2.local:7:AWS_SQS_URL=http://localstack:4566/000000000000/togglemaster-events
fase2/docker/.env.phase2.local:8:AWS_DYNAMODB_TABLE=ToggleMasterAnalytics
fase2/docker/docker-compose.phase2-exec.yaml:70:      --attribute-definitions AttributeName=event_id,AttributeType=S
fase2/docker/docker-compose.phase2-exec.yaml:71:      --key-schema AttributeName=event_id,KeyType=HASH
fase2/docker/docker-compose.phase2-exec.yaml:138:      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
fase2/docker/docker-compose.phase2-exec.yaml:157:      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
fase2/docker/docker-compose.phase2-exec.yaml:158:      AWS_DYNAMODB_TABLE: ToggleMasterAnalytics
fase2/docker/.env.example:13:AWS_SQS_URL=http://localstack:4566/000000000000/togglemaster-events
fase2/src/services/targeting-service/app.py:76:    if not data or 'flag_name' not in data or 'rules' not in data:
fase2/src/services/targeting-service/app.py:77:        return jsonify({"error": "'flag_name' e 'rules' (JSON) são obrigatórios"}), 400
fase2/src/services/targeting-service/app.py:79:    flag_name = data['flag_name']
fase2/src/services/targeting-service/app.py:89:            "INSERT INTO targeting_rules (flag_name, is_enabled, rules, created_at, updated_at) "
fase2/src/services/targeting-service/app.py:91:            (flag_name, is_enabled, Json(rules_obj)) # Usa Json() para serializar
fase2/src/services/targeting-service/app.py:95:        log.info(f"Regra para '{flag_name}' criada com sucesso.")
fase2/src/services/targeting-service/app.py:99:        log.warning(f"Tentativa de criar regra duplicada: '{flag_name}'")
fase2/src/services/targeting-service/app.py:100:        return jsonify({"error": f"Regra para a flag '{flag_name}' já existe"}), 409
fase2/src/services/targeting-service/app.py:109:@app.route('/rules/<string:flag_name>', methods=['GET'])
fase2/src/services/targeting-service/app.py:111:def get_rule(flag_name):
fase2/src/services/targeting-service/app.py:118:        cur.execute("SELECT * FROM targeting_rules WHERE flag_name = %s", (flag_name,))
fase2/src/services/targeting-service/app.py:124:        log.error(f"Erro ao buscar regra '{flag_name}': {e}")
fase2/src/services/targeting-service/app.py:130:@app.route('/rules/<string:flag_name>', methods=['PUT'])
fase2/src/services/targeting-service/app.py:132:def update_rule(flag_name):
fase2/src/services/targeting-service/app.py:151:    values.append(flag_name) # Adiciona o 'flag_name' para a cláusula WHERE
fase2/src/services/targeting-service/app.py:153:    query = f"UPDATE targeting_rules SET {', '.join(fields)} WHERE flag_name = %s RETURNING *"
fase2/src/services/targeting-service/app.py:167:        log.info(f"Regra para '{flag_name}' atualizada com sucesso.")
fase2/src/services/targeting-service/app.py:171:        log.error(f"Erro ao atualizar regra '{flag_name}': {e}")
fase2/src/services/targeting-service/app.py:177:@app.route('/rules/<string:flag_name>', methods=['DELETE'])
fase2/src/services/targeting-service/app.py:179:def delete_rule(flag_name):
fase2/src/services/targeting-service/app.py:186:        cur.execute("DELETE FROM targeting_rules WHERE flag_name = %s", (flag_name,))
fase2/src/services/targeting-service/app.py:192:        log.info(f"Regra para '{flag_name}' deletada com sucesso.")
fase2/src/services/targeting-service/app.py:196:        log.error(f"Erro ao deletar regra '{flag_name}': {e}")
fase2/src/services/targeting-service/db/init.sql:4:    -- 'flag_name' é a chave de negócio única. 
fase2/src/services/targeting-service/db/init.sql:6:    flag_name VARCHAR(100) UNIQUE NOT NULL,
fase2/src/services/evaluation-service/sqs.go:14:	UserID    string    `json:"user_id"`
fase2/src/services/evaluation-service/sqs.go:15:	FlagName  string    `json:"flag_name"`
fase2/src/services/evaluation-service/sqs.go:16:	Result    bool      `json:"result"`
fase2/src/services/evaluation-service/sqs.go:21:func (a *App) sendEvaluationEvent(userID, flagName string, result bool) {
fase2/src/services/evaluation-service/sqs.go:24:		log.Printf("[SQS_DISABLED] Evento: User '%s', Flag '%s', Result '%t'", userID, flagName, result)
fase2/src/services/evaluation-service/sqs.go:31:		Result:    result,
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:55:	sqsQueueURL := os.Getenv("AWS_SQS_URL")
fase2/src/services/evaluation-service/main.go.bak.bloco17-localstack-sqs-20260522-125909:58:		log.Println("Atenção: AWS_SQS_URL não definida. Eventos não serão enviados.")
fase2/src/services/evaluation-service/main.go:56:	sqsQueueURL := os.Getenv("AWS_SQS_URL")
fase2/src/services/evaluation-service/main.go:59:		log.Println("Atenção: AWS_SQS_URL não definida. Eventos não serão enviados.")
fase2/src/services/evaluation-service/handlers.go:10:	FlagName string `json:"flag_name"`
fase2/src/services/evaluation-service/handlers.go:11:	UserID   string `json:"user_id"`
fase2/src/services/evaluation-service/handlers.go:12:	Result   bool   `json:"result"`
fase2/src/services/evaluation-service/handlers.go:25:	userID := r.URL.Query().Get("user_id")
fase2/src/services/evaluation-service/handlers.go:26:	flagName := r.URL.Query().Get("flag_name")
fase2/src/services/evaluation-service/handlers.go:29:		http.Error(w, `{"error": "user_id e flag_name são obrigatórios"}`, http.StatusBadRequest)
fase2/src/services/evaluation-service/handlers.go:34:	result, err := a.getDecision(userID, flagName)
fase2/src/services/evaluation-service/handlers.go:38:			result = false
fase2/src/services/evaluation-service/handlers.go:49:	go a.sendEvaluationEvent(userID, flagName, result)
fase2/src/services/evaluation-service/handlers.go:56:		Result:   result,
fase2/src/services/evaluation-service/types.go:18:	FlagName  string `json:"flag_name"`
fase2/src/services/analytics-service/app.py:22:SQS_QUEUE_URL = os.getenv("AWS_SQS_URL")
fase2/src/services/analytics-service/app.py:23:DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")
fase2/src/services/analytics-service/app.py:27:    log.critical("Erro: AWS_REGION, AWS_SQS_URL, e AWS_DYNAMODB_TABLE devem ser definidos.")
fase2/src/services/analytics-service/app.py:60:        event_id = str(uuid.uuid4())
fase2/src/services/analytics-service/app.py:64:            'event_id': {'S': event_id},
fase2/src/services/analytics-service/app.py:65:            'user_id': {'S': body['user_id']},
fase2/src/services/analytics-service/app.py:66:            'flag_name': {'S': body['flag_name']},
fase2/src/services/analytics-service/app.py:67:            'result': {'BOOL': body['result']},
fase2/src/services/analytics-service/app.py:72:        dynamodb_client.put_item(
fase2/src/services/analytics-service/app.py:77:        log.info(f"Evento {event_id} (Flag: {body['flag_name']}) salvo no DynamoDB.")
fase2/src/services/analytics-service/app.py:80:        sqs_client.delete_message(
fase2/src/services/analytics-service/app.py:101:            response = sqs_client.receive_message(
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:22:SQS_QUEUE_URL = os.getenv("AWS_SQS_URL")
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:23:DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:26:    log.critical("Erro: AWS_REGION, AWS_SQS_URL, e AWS_DYNAMODB_TABLE devem ser definidos.")
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:53:        event_id = str(uuid.uuid4())
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:57:            'event_id': {'S': event_id},
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:58:            'user_id': {'S': body['user_id']},
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:59:            'flag_name': {'S': body['flag_name']},
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:60:            'result': {'BOOL': body['result']},
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:65:        dynamodb_client.put_item(
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:70:        log.info(f"Evento {event_id} (Flag: {body['flag_name']}) salvo no DynamoDB.")
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:73:        sqs_client.delete_message(
fase2/src/services/analytics-service/app.py.bak.bloco17-localstack-boto3-20260522-130356:94:            response = sqs_client.receive_message(
fase2/repos/upstream/targeting-service/app.py:76:    if not data or 'flag_name' not in data or 'rules' not in data:
fase2/repos/upstream/targeting-service/app.py:77:        return jsonify({"error": "'flag_name' e 'rules' (JSON) são obrigatórios"}), 400
fase2/repos/upstream/targeting-service/app.py:79:    flag_name = data['flag_name']
fase2/repos/upstream/targeting-service/app.py:89:            "INSERT INTO targeting_rules (flag_name, is_enabled, rules, created_at, updated_at) "
fase2/repos/upstream/targeting-service/app.py:91:            (flag_name, is_enabled, Json(rules_obj)) # Usa Json() para serializar
fase2/repos/upstream/targeting-service/app.py:95:        log.info(f"Regra para '{flag_name}' criada com sucesso.")
fase2/repos/upstream/targeting-service/app.py:99:        log.warning(f"Tentativa de criar regra duplicada: '{flag_name}'")
fase2/repos/upstream/targeting-service/app.py:100:        return jsonify({"error": f"Regra para a flag '{flag_name}' já existe"}), 409
fase2/repos/upstream/targeting-service/app.py:109:@app.route('/rules/<string:flag_name>', methods=['GET'])
fase2/repos/upstream/targeting-service/app.py:111:def get_rule(flag_name):
fase2/repos/upstream/targeting-service/app.py:118:        cur.execute("SELECT * FROM targeting_rules WHERE flag_name = %s", (flag_name,))
fase2/repos/upstream/targeting-service/app.py:124:        log.error(f"Erro ao buscar regra '{flag_name}': {e}")
fase2/repos/upstream/targeting-service/app.py:130:@app.route('/rules/<string:flag_name>', methods=['PUT'])
fase2/repos/upstream/targeting-service/app.py:132:def update_rule(flag_name):
fase2/repos/upstream/targeting-service/app.py:151:    values.append(flag_name) # Adiciona o 'flag_name' para a cláusula WHERE
fase2/repos/upstream/targeting-service/app.py:153:    query = f"UPDATE targeting_rules SET {', '.join(fields)} WHERE flag_name = %s RETURNING *"
fase2/repos/upstream/targeting-service/app.py:167:        log.info(f"Regra para '{flag_name}' atualizada com sucesso.")
fase2/repos/upstream/targeting-service/app.py:171:        log.error(f"Erro ao atualizar regra '{flag_name}': {e}")
fase2/repos/upstream/targeting-service/app.py:177:@app.route('/rules/<string:flag_name>', methods=['DELETE'])
fase2/repos/upstream/targeting-service/app.py:179:def delete_rule(flag_name):
fase2/repos/upstream/targeting-service/app.py:186:        cur.execute("DELETE FROM targeting_rules WHERE flag_name = %s", (flag_name,))
fase2/repos/upstream/targeting-service/app.py:192:        log.info(f"Regra para '{flag_name}' deletada com sucesso.")
fase2/repos/upstream/targeting-service/app.py:196:        log.error(f"Erro ao deletar regra '{flag_name}': {e}")
fase2/repos/upstream/targeting-service/db/init.sql:4:    -- 'flag_name' é a chave de negócio única. 
fase2/repos/upstream/targeting-service/db/init.sql:6:    flag_name VARCHAR(100) UNIQUE NOT NULL,
fase2/repos/upstream/evaluation-service/sqs.go:14:	UserID    string    `json:"user_id"`
fase2/repos/upstream/evaluation-service/sqs.go:15:	FlagName  string    `json:"flag_name"`
fase2/repos/upstream/evaluation-service/sqs.go:16:	Result    bool      `json:"result"`
fase2/repos/upstream/evaluation-service/sqs.go:21:func (a *App) sendEvaluationEvent(userID, flagName string, result bool) {
fase2/repos/upstream/evaluation-service/sqs.go:24:		log.Printf("[SQS_DISABLED] Evento: User '%s', Flag '%s', Result '%t'", userID, flagName, result)
fase2/repos/upstream/evaluation-service/sqs.go:31:		Result:    result,
fase2/repos/upstream/evaluation-service/main.go:55:	sqsQueueURL := os.Getenv("AWS_SQS_URL")
fase2/repos/upstream/evaluation-service/main.go:58:		log.Println("Atenção: AWS_SQS_URL não definida. Eventos não serão enviados.")
fase2/repos/upstream/evaluation-service/handlers.go:10:	FlagName string `json:"flag_name"`
fase2/repos/upstream/evaluation-service/handlers.go:11:	UserID   string `json:"user_id"`
fase2/repos/upstream/evaluation-service/handlers.go:12:	Result   bool   `json:"result"`
fase2/repos/upstream/evaluation-service/handlers.go:25:	userID := r.URL.Query().Get("user_id")
fase2/repos/upstream/evaluation-service/handlers.go:26:	flagName := r.URL.Query().Get("flag_name")
fase2/repos/upstream/evaluation-service/handlers.go:29:		http.Error(w, `{"error": "user_id e flag_name são obrigatórios"}`, http.StatusBadRequest)
fase2/repos/upstream/evaluation-service/handlers.go:34:	result, err := a.getDecision(userID, flagName)
fase2/repos/upstream/evaluation-service/handlers.go:38:			result = false
fase2/repos/upstream/evaluation-service/handlers.go:49:	go a.sendEvaluationEvent(userID, flagName, result)
fase2/repos/upstream/evaluation-service/handlers.go:56:		Result:   result,
fase2/repos/upstream/evaluation-service/types.go:18:	FlagName   string `json:"flag_name"`
fase2/repos/upstream/analytics-service/app.py:22:SQS_QUEUE_URL = os.getenv("AWS_SQS_URL")
fase2/repos/upstream/analytics-service/app.py:23:DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")
fase2/repos/upstream/analytics-service/app.py:26:    log.critical("Erro: AWS_REGION, AWS_SQS_URL, e AWS_DYNAMODB_TABLE devem ser definidos.")
fase2/repos/upstream/analytics-service/app.py:53:        event_id = str(uuid.uuid4())
fase2/repos/upstream/analytics-service/app.py:57:            'event_id': {'S': event_id},
fase2/repos/upstream/analytics-service/app.py:58:            'user_id': {'S': body['user_id']},
fase2/repos/upstream/analytics-service/app.py:59:            'flag_name': {'S': body['flag_name']},
fase2/repos/upstream/analytics-service/app.py:60:            'result': {'BOOL': body['result']},
fase2/repos/upstream/analytics-service/app.py:65:        dynamodb_client.put_item(
fase2/repos/upstream/analytics-service/app.py:70:        log.info(f"Evento {event_id} (Flag: {body['flag_name']}) salvo no DynamoDB.")
fase2/repos/upstream/analytics-service/app.py:73:        sqs_client.delete_message(
fase2/repos/upstream/analytics-service/app.py:94:            response = sqs_client.receive_message(
fase2/local/scripts/17_validate_phase2_e2e_flow.sh:243:      \"flag_name\":\"$FLAG_NAME\",
fase2/local/scripts/17_validate_phase2_e2e_flow.sh:280:    "http://localhost:8004/evaluate?user_id=$user&flag_name=$FLAG_NAME" \
fase2/local/scripts/17_validate_phase2_e2e_flow.sh:284:  if ! grep -q '"flag_name":"'"$FLAG_NAME"'"' "$BASE/logs/fase2-bloco17-evaluate-$user.log"; then
fase2/local/scripts/12_apply_runtime_patches.sh:297:        'DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")\n',
fase2/local/scripts/12_apply_runtime_patches.sh:298:        'DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")\n'
fase2/local/scripts/15_fix_phase2_compose_runtime.sh.bak.pre-consolidacao-20260522-132335:42:AWS_SQS_URL=http://localstack:4566/000000000000/togglemaster-events
fase2/local/scripts/15_fix_phase2_compose_runtime.sh.bak.pre-consolidacao-20260522-132335:110:      --attribute-definitions AttributeName=event_id,AttributeType=S
fase2/local/scripts/15_fix_phase2_compose_runtime.sh.bak.pre-consolidacao-20260522-132335:111:      --key-schema AttributeName=event_id,KeyType=HASH
fase2/local/scripts/15_fix_phase2_compose_runtime.sh.bak.pre-consolidacao-20260522-132335:168:      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
fase2/local/scripts/15_fix_phase2_compose_runtime.sh.bak.pre-consolidacao-20260522-132335:186:      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:43:AWS_SQS_URL=http://localstack:4566/000000000000/togglemaster-events
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:44:AWS_DYNAMODB_TABLE=ToggleMasterAnalytics
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:121:      --attribute-definitions AttributeName=event_id,AttributeType=S
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:122:      --key-schema AttributeName=event_id,KeyType=HASH
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:189:      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:208:      AWS_SQS_URL: http://localstack:4566/000000000000/togglemaster-events
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:209:      AWS_DYNAMODB_TABLE: ToggleMasterAnalytics
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:225:grep -nE 'auth-service:|flag-service:|targeting-service:|evaluation-service:|analytics-service:|PORT:|AUTH_SERVICE_URL|SERVICE_API_KEY|REDIS_URL|AWS_ENDPOINT_URL|AWS_SQS_URL|AWS_DYNAMODB_TABLE|DATABASE_URL|MASTER_KEY' \
fase2/local/scripts/15_fix_phase2_compose_runtime.sh:253:- \`analytics-service\` com \`AWS_DYNAMODB_TABLE=ToggleMasterAnalytics\`.
fase2/local/scripts/17_validate_phase2_e2e_flow.sh.bak.pre-final-20260522-131155:150:  -d '{"flag_name":"enable-new-dashboard","rule_type":"PERCENTAGE","rule_value":"50"}' \
fase2/local/scripts/17_validate_phase2_e2e_flow.sh.bak.pre-final-20260522-131155:165:    -d "{\"flag_name\":\"enable-new-dashboard\",\"user_id\":\"$user\"}" \
fase2/local/scripts/12_apply_runtime_patches.sh.bak.fix-go-build-output-20260522-135156:297:        'DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")\n',
fase2/local/scripts/12_apply_runtime_patches.sh.bak.fix-go-build-output-20260522-135156:298:        'DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")\n'
fase2/local/scripts/16_stabilize_phase2_runtime.sh.bak.pre-consolidacao-20260522-132631:72:  --attribute-definitions AttributeName=event_id,AttributeType=S \
fase2/local/scripts/16_stabilize_phase2_runtime.sh.bak.pre-consolidacao-20260522-132631:73:  --key-schema AttributeName=event_id,KeyType=HASH \
fase2/local/scripts/17_9_fix_missing_envs_flag_targeting_analytics.sh:94:lines = set_env(lines, "analytics-service", "AWS_DYNAMODB_TABLE", "ToggleMasterAnalytics")

```

RC grep: `141`

## 5. Enviar mensagem sintética para SQS


### Evento sintético enviado

```json
{
  "event_id": "phase3-bloco19-4-20260523134512",
  "flag_name": "enable-new-dashboard",
  "user_id": "synthetic-phase3-bloco19-4-20260523134512",
  "result": true,
  "value": true,
  "timestamp": "2026-05-23T16:45:12Z",
  "source": "phase3-bloco19-4-diagnostic"
}

```

### Enviar mensagem sintética para SQS

```bash
$ aws sqs send-message --region us-east-1 --queue-url https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events --message-body file:///home/wellk/togglemaster-tc/fase3/tmp/bloco19-4/synthetic-event.json
{
    "MD5OfMessageBody": "7725e8af31243dcdba8c69ceedb88f5a",
    "MessageId": "24ecbfdb-080a-4ede-8bb2-e1a72196691e"
}

```

RC: `0`

## 6. Aguardar consumo e verificar fila


### Atributos SQS após mensagem sintética

```bash
$ aws sqs get-queue-attributes --region us-east-1 --queue-url https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible ApproximateNumberOfMessagesDelayed
{
    "Attributes": {
        "ApproximateNumberOfMessages": "1",
        "ApproximateNumberOfMessagesNotVisible": "0",
        "ApproximateNumberOfMessagesDelayed": "0"
    }
}

```

RC: `0`

## 7. Validar DynamoDB após mensagem sintética

- DynamoDB Count depois: `3`

### Busca do evento sintético no DynamoDB

```json
{
    "Items": [],
    "Count": 0,
    "ScannedCount": 3,
    "ConsumedCapacity": null
}

```

RC busca: `0`

## 8. Logs recentes depois da mensagem sintética


### Logs evaluation-service depois

```bash
$ kubectl logs -n togglemaster deployment/evaluation-service --tail=160
Found 2 pods, using pod/evaluation-service-6658f5d98c-77lkz
2026/05/23 06:24:13 Conectado ao Redis com sucesso!
2026/05/23 06:24:13 Cliente SQS inicializado com sucesso.
2026/05/23 06:24:13 Serviço de Avaliação (Go) rodando na porta 8000
2026/05/23 16:43:17 Cache MISS para flag 'enable-new-dashboard'
2026/05/23 16:43:18 Erro ao enviar mensagem para SQS: ExpiredToken: The security token included in the request is expired
	status code: 403, request id: d78c5362-a8c1-523f-8609-31e973a76dbe
2026/05/23 16:43:18 Cache HIT para flag 'enable-new-dashboard'
2026/05/23 16:43:18 Erro ao enviar mensagem para SQS: ExpiredToken: The security token included in the request is expired
	status code: 403, request id: 71025be0-4b53-55cb-8af2-396b9035d06c
2026/05/23 16:43:18 Cache HIT para flag 'enable-new-dashboard'
2026/05/23 16:43:19 Erro ao enviar mensagem para SQS: ExpiredToken: The security token included in the request is expired
	status code: 403, request id: 0d4e6546-2020-5e30-8e0c-07cdfb47faa2

```

RC: `0`

### Logs analytics-service depois

```bash
$ kubectl logs -n togglemaster deployment/analytics-service --tail=220
2026-05-23 16:09:08,681 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:09:18,711 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:09:28,737 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:09:38,767 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:09:48,830 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:09:58,857 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:10:08,885 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:10:18,913 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:10:28,942 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:10:38,967 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:10:48,992 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:10:59,031 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:11:09,057 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:11:19,085 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:11:29,113 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:11:39,139 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:11:49,166 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:11:59,199 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:12:09,234 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:12:19,264 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:12:29,295 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:12:39,323 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:12:49,351 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:12:59,376 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:13:09,404 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:13:19,429 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:13:29,457 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:13:39,504 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:13:49,531 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:13:59,556 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:14:09,583 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:14:19,609 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:14:29,637 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:14:39,664 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:14:49,692 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:14:59,719 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:15:09,747 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:15:19,773 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:15:29,803 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:15:39,832 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:15:49,865 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:15:59,896 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:16:09,928 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:16:19,959 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:16:29,986 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:16:40,013 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:16:50,048 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:17:00,104 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:17:10,132 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:17:20,160 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:17:30,186 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:17:40,211 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:17:50,239 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:18:00,269 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:18:10,299 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:18:20,328 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:18:30,356 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:18:40,384 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:18:50,413 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:00,440 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:10,469 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:20,496 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:30,521 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:40,549 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:19:50,576 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:00,601 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:10,627 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:20,657 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:30,686 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:40,712 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:20:50,751 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:00,777 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:10,813 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:20,840 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:30,868 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:40,901 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:21:50,930 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:00,956 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:10,985 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:21,014 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:31,046 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:41,072 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:22:51,100 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:01,130 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:11,156 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:21,183 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:31,213 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:41,241 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:23:51,277 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:01,325 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:11,352 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:21,377 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:31,403 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:41,430 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:24:51,460 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:01,499 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:11,529 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:21,557 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:31,593 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:41,619 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:25:51,648 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:01,691 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:11,718 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:21,752 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:31,782 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:41,810 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:26:51,844 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:02,065 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:12,093 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:22,127 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:32,156 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:42,188 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:27:52,215 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:02,266 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:12,304 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:22,330 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:32,369 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:42,400 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:28:52,429 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:02,471 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:12,509 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:22,537 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:32,562 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:42,591 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:29:52,618 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:02,783 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:12,810 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:22,840 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:32,865 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:42,889 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:30:52,916 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:02,943 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:12,972 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:22,996 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:33,033 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:43,064 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:31:53,089 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:03,116 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:13,143 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:23,171 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:33,250 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:43,278 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:32:53,306 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:03,338 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:13,373 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:23,401 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:33,428 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:43,466 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:33:53,496 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:03,523 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:13,552 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:23,582 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:33,607 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:43,638 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:34:53,668 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:03,703 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:13,734 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:23,761 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:33,787 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:43,815 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:35:53,845 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:03,879 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:13,907 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:23,933 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:33,959 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:43,987 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:36:54,021 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:04,048 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:14,079 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:24,106 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:34,134 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:44,161 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:37:54,191 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:04,222 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:14,251 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:24,285 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:34,313 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:44,351 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:38:54,378 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:04,419 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:14,446 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:24,472 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:34,498 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:44,525 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:39:54,550 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:04,580 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:14,609 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:24,644 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:34,679 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:44,709 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:40:54,739 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:04,768 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:14,795 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:24,823 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:34,849 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:44,884 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:41:54,910 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:04,950 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:14,980 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:25,015 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:35,042 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:45,067 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:42:55,095 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:05,123 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:15,148 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:25,196 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:35,226 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:45,253 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:43:55,281 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:05,312 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:15,359 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:25,386 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:35,451 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:45,479 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:44:55,508 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:45:05,548 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:45:15,577 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:45:25,604 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:45:35,630 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired
2026-05-23 16:45:45,656 - ERROR - Erro do Boto3 no loop principal do SQS: An error occurred (ExpiredToken) when calling the ReceiveMessage operation: The security token included in the request is expired

```

RC: `0`

## 9. Resultado


## Resultado

- DynamoDB antes: `3`
- DynamoDB depois: `3`
- Evento sintético encontrado no DynamoDB: `0`
- Log completo: `/home/wellk/togglemaster-tc/fase3/logs/fase3-bloco19-4-diagnostico-async.log`
