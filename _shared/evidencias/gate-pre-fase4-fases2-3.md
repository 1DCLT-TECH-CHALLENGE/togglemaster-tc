# Gate Consolidado Pré-Fase 4 — Fases 2 e 3

Data: Sat May 23 02:40:50 PM -03 2026

## Objetivo

Registrar um checkpoint consolidado antes de iniciar a Fase 4.

Este gate confirma que:

- A Fase 2 local está funcional.
- A Fase 3 cloud está funcional.
- A base Kubernetes/GitOps/IaC/DevSecOps da Fase 3 permanece presente e validada por evidências.
- O Git está limpo, exceto pelos próprios arquivos deste gate antes do commit.
- A Fase 4 será iniciada como entrega real da fase, não como rebuild.

## Observação importante

A Fase 4 não será tratada como rebuild. Ela será conduzida como entrega acadêmica completa, com implementação, evidências, relatório, prints e roteiro de vídeo.


## 1. Estado Git e commits


### Git status inicial

```bash
$ git status --short
?? _shared/evidencias/gate-pre-fase4-fases2-3.md
?? _shared/scripts/21_gate_pre_fase4_fases2_3.sh

```

RC: `0`

### Últimos commits

```bash
$ git log --oneline --decorate -10
e38cf8d (HEAD -> main, origin/main) fix: prevent phase 2 e2e from persisting runtime api key
d7666dd docs: record phase 2 local pre phase 4 revalidation
eab9b9d docs: record phase 3 pre phase 4 app validation
c597af1 docs: record phase 3 pre phase 4 checkpoint
9c2f944 docs: record phase 3 gitops cloud e2e validation
621563e fix: avoid extra pods during rolling updates
ca88c71 feat: reference runtime secret in gitops deployments
3d9e445 docs: record phase 3 pod credentials diagnosis
0f2037a docs: record phase 3 pod aws credentials test
bfdc4a2 feat: add non sensitive runtime config to gitops

```

RC: `0`

### Branch atual

```bash
$ git branch --show-current
main

```

RC: `0`
- OK: Git limpo, exceto artefatos esperados do próprio gate.

## 2. Confirmação robusta da Fase 2 local

- OK: evidência do BLOCO 20 comprova scripts 16 e 17 com retorno 0.
- OK: log do BLOCO 20 comprova runtime e E2E local da Fase 2.

### Resumo recente da revalidação local da Fase 2

Arquivo: `fase2/logs/fase2-bloco20-revalidacao-local-pre-fase4.log`

```text
analytics-service-1  | 2026-05-23 17:26:11,841 - INFO - Evento d9a2c996-8447-45c4-bcec-e24263ca2e02 (Flag: enable-new-dashboard) salvo no DynamoDB.

[12/12] DynamoDB LocalStack: scan final
{
    "Items": [
        {
            "result": {
                "BOOL": true
            },
            "event_id": {
                "S": "341c7dcb-d5f7-4e46-bdd0-c5fe492ca8d1"
            },
            "user_id": {
                "S": "user-123"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-23T17:26:11.751100284Z"
            }
        },
        {
            "result": {
                "BOOL": true
            },
            "event_id": {
                "S": "d9a2c996-8447-45c4-bcec-e24263ca2e02"
            },
            "user_id": {
                "S": "user-123-sqs"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-23T17:26:11.775977103Z"
            }
        },
        {
            "result": {
                "BOOL": false
            },
            "event_id": {
                "S": "6784b8c6-7f81-4226-8f29-cf03a283fb6b"
            },
            "user_id": {
                "S": "user-abc"
            },
            "flag_name": {
                "S": "enable-new-dashboard"
            },
            "timestamp": {
                "S": "2026-05-23T17:26:11.765969979Z"
            }
        }
    ],
    "Count": 3,
    "ScannedCount": 3,
    "ConsumedCapacity": null
}

OK: DynamoDB scan retornou Count=3.

============================================================
BLOCO 17 FINALIZADO COM SUCESSO
Log: /home/wellk/togglemaster-tc/fase2/logs/fase2-bloco17-e2e-flow.log
Evidência: /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-validacao-e2e.md
DynamoDB Count: 3
============================================================

S17_RC=0

============================================================
5. Coletar resumo pós-validação
============================================================


### Containers relacionados à Fase 2
$ docker ps --format table {{.Names}}\t{{.Status}}\t{{.Ports}}

NAMES                         STATUS                    PORTS
docker-evaluation-service-1   Up 28 seconds             0.0.0.0:8004->8000/tcp, [::]:8004->8000/tcp
docker-flag-service-1         Up 51 seconds             0.0.0.0:8002->8000/tcp, [::]:8002->8000/tcp
docker-targeting-service-1    Up 51 seconds             0.0.0.0:8003->8000/tcp, [::]:8003->8000/tcp
docker-analytics-service-1    Up 50 seconds             0.0.0.0:8005->8000/tcp, [::]:8005->8000/tcp
docker-auth-service-1         Up 51 seconds             0.0.0.0:8001->8000/tcp, [::]:8001->8000/tcp
docker-postgres-targeting-1   Up 16 minutes             0.0.0.0:5435->5432/tcp, [::]:5435->5432/tcp
docker-postgres-flags-1       Up 16 minutes             0.0.0.0:5434->5432/tcp, [::]:5434->5432/tcp
docker-postgres-auth-1        Up 16 minutes             0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp
docker-redis-1                Up 16 minutes             0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
docker-localstack-1           Up 16 minutes (healthy)   4510-4559/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp, [::]:4566->4566/tcp

RC=0

Buscando evidência final do BLOCO 17, se existir...
2026-05-22 12:09 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-3-reparo-imports-go.md
2026-05-22 12:12 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-4-correcao-localstack-exec.md
2026-05-22 12:14 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-5-diagnostico-servicos-ausentes.md
2026-05-22 12:16 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-6-correcao-startup-redis.md
2026-05-22 12:18 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-7-correcao-auth-port-redis-url.md
2026-05-22 12:19 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-8-correcao-porta-evaluation.md
2026-05-22 12:27 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-9-correcao-envs-servicos-python.md
2026-05-22 13:06 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-e2e-validado.md
2026-05-22 13:30 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco18-consolidacao-pos-e2e.md
2026-05-23 14:26 /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco17-validacao-e2e.md

============================================================
6. Resultado
============================================================


============================================================
BLOCO 20 CONCLUÍDO COM SUCESSO
Fase 2 local revalidada pré-Fase 4.
S16_RC=0
S17_RC=0
Log: /home/wellk/togglemaster-tc/fase2/logs/fase2-bloco20-revalidacao-local-pre-fase4.log
Evidência: /home/wellk/togglemaster-tc/fase2/docs/evidencias/fase2-bloco20-revalidacao-local-pre-fase4.md
============================================================

```

## 3. Confirmação robusta da Fase 3 cloud

- OK: evidência do BLOCO 18 comprova checkpoint cloud/GitOps da Fase 3.
- OK: evidência/log do BLOCO 19 comprovam validação funcional cloud da Fase 3.
- OK: diagnóstico assíncrono da Fase 3 documentado.
- OK: renovação de credenciais dos pods documentada.

### Resumo recente da validação funcional da Fase 3

Arquivo: `fase3/logs/fase3-bloco19-validacao-apps-pre-fase4.log`

```text
HTTP_STATUS=200
{"flag_name": "enable-new-dashboard", "user_id": "user-123", "result": true}

OK: Evaluation user-123 retornou HTTP 200

Avaliando user-abc

### Evaluation GET - user-abc
HTTP_STATUS=200
{"flag_name": "enable-new-dashboard", "user_id": "user-abc", "result": false}

OK: Evaluation user-abc retornou HTTP 200

Avaliando user-123-sqs

### Evaluation GET - user-123-sqs
HTTP_STATUS=200
{"flag_name": "enable-new-dashboard", "user_id": "user-123-sqs", "result": true}

OK: Evaluation user-123-sqs retornou HTTP 200

============================================================
10. Validar SQS, analytics-service e DynamoDB
============================================================

Aguardando analytics-service consumir mensagens...

Atributos SQS após avaliações:
{
    "Attributes": {
        "ApproximateNumberOfMessages": "0",
        "ApproximateNumberOfMessagesNotVisible": "0",
        "ApproximateNumberOfMessagesDelayed": "0"
    }
}

DDB_COUNT_AFTER=7

============================================================
11. Logs recentes dos serviços
============================================================


### Logs evaluation-service
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

RC=0

### Logs analytics-service
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

RC=0

============================================================
12. Estado final
============================================================


### ArgoCD final
$ kubectl get application togglemaster-dev -n argocd -o wide

NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         c597af16d98f2bc0937d4e165966971f66fd6c47   default

RC=0

### Pods finais
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

RC=0

============================================================
BLOCO 19 CONCLUÍDO COM SUCESSO
Aplicações da Fase 3 validadas funcionalmente pré-Fase 4.
DynamoDB antes: 4
DynamoDB depois: 7
Log: /home/wellk/togglemaster-tc/fase3/logs/fase3-bloco19-validacao-apps-pre-fase4.log
Evidência: /home/wellk/togglemaster-tc/fase3/docs/evidencias/fase3-bloco19-validacao-apps-pre-fase4.md
============================================================

Encerrando port-forwards...

```

## 4. Estado atual read-only da Fase 3 cloud


### AWS identity atual

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

### Clusters EKS

```bash
$ aws eks list-clusters --region us-east-1 --output table
----------------------------
|       ListClusters       |
+--------------------------+
||        clusters        ||
|+------------------------+|
||  togglemaster-dev-eks  ||
|+------------------------+|

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
togglemaster-dev   Synced        Healthy         e38cf8d463217c34229c26f044469400df6f6e59   default

```

RC: `0`

### Pods namespace togglemaster

```bash
$ kubectl get pods -n togglemaster -o wide
NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-6946467b6b-9fvmm    1/1     Running   0          28m   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
auth-service-584688f79d-vpg2z         1/1     Running   0          11h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
auth-service-584688f79d-xt6v8         1/1     Running   0          11h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
evaluation-service-7949b95dd5-kf2md   1/1     Running   0          28m   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
evaluation-service-7949b95dd5-wbrlc   1/1     Running   0          28m   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-9ffxm         1/1     Running   0          11h   10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
flag-service-7cd69f6bf9-x7pxc         1/1     Running   0          11h   10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-7zc9d    1/1     Running   0          11h   10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
targeting-service-66d4bb78b6-8tw7t    1/1     Running   0          11h   10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>

```

RC: `0`

### Services namespace togglemaster

```bash
$ kubectl get svc -n togglemaster -o wide
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
analytics-service    ClusterIP   172.20.81.122   <none>        8000/TCP   13h   app.kubernetes.io/name=analytics-service
auth-service         ClusterIP   172.20.222.48   <none>        8000/TCP   13h   app.kubernetes.io/name=auth-service
evaluation-service   ClusterIP   172.20.66.90    <none>        8000/TCP   13h   app.kubernetes.io/name=evaluation-service
flag-service         ClusterIP   172.20.51.154   <none>        8000/TCP   13h   app.kubernetes.io/name=flag-service
targeting-service    ClusterIP   172.20.90.181   <none>        8000/TCP   13h   app.kubernetes.io/name=targeting-service

```

RC: `0`

### Resultado atual Kubernetes/GitOps

- ArgoCD: `Synced/Healthy`
- Pods não prontos: nenhum.

## 5. Artefatos de IaC, GitOps, automação e DevSecOps da Fase 3


### Terraform files

```bash
$ bash -lc find fase3/terraform -maxdepth 4 -type f | sort
fase3/terraform/environments/dev/backend.example.hcl
fase3/terraform/environments/dev/main.tf
fase3/terraform/environments/dev/outputs.tf
fase3/terraform/environments/dev/providers.tf
fase3/terraform/environments/dev/.terraform.lock.hcl
fase3/terraform/environments/dev/terraform.tfstate
fase3/terraform/environments/dev/terraform.tfstate.backup
fase3/terraform/environments/dev/terraform.tfvars.example
fase3/terraform/environments/dev/variables.tf
fase3/terraform/environments/dev/versions.tf
fase3/terraform/modules/dynamodb/main.tf
fase3/terraform/modules/dynamodb/outputs.tf
fase3/terraform/modules/dynamodb/variables.tf
fase3/terraform/modules/ecr/main.tf
fase3/terraform/modules/ecr/outputs.tf
fase3/terraform/modules/ecr/variables.tf
fase3/terraform/modules/eks/main.tf
fase3/terraform/modules/eks/outputs.tf
fase3/terraform/modules/eks/variables.tf
fase3/terraform/modules/elasticache/main.tf
fase3/terraform/modules/elasticache/outputs.tf
fase3/terraform/modules/elasticache/variables.tf
fase3/terraform/modules/networking/main.tf
fase3/terraform/modules/networking/outputs.tf
fase3/terraform/modules/networking/variables.tf
fase3/terraform/modules/rds/main.tf
fase3/terraform/modules/rds/outputs.tf
fase3/terraform/modules/rds/variables.tf
fase3/terraform/modules/secrets/main.tf
fase3/terraform/modules/secrets/outputs.tf
fase3/terraform/modules/secrets/variables.tf
fase3/terraform/modules/security/main.tf
fase3/terraform/modules/security/outputs.tf
fase3/terraform/modules/security/variables.tf
fase3/terraform/modules/sqs/main.tf
fase3/terraform/modules/sqs/outputs.tf
fase3/terraform/modules/sqs/variables.tf
fase3/terraform/README.md

```

RC: `0`

### GitOps files

```bash
$ bash -lc find fase3/gitops -maxdepth 5 -type f | sort
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

```

RC: `0`

### GitHub Actions workflows

```bash
$ bash -lc find .github/workflows -maxdepth 1 -type f | sort
.github/workflows/phase3-gitops-validate.yml
.github/workflows/phase3-security-scan.yml
.github/workflows/phase3-terraform-validate.yml

```

RC: `0`

### Scripts locais Fase 3

```bash
$ bash -lc find fase3/local/scripts -maxdepth 1 -type f | sort
fase3/local/scripts/01_validate_phase3_offline.sh
fase3/local/scripts/18_checkpoint_retomada_pre_fase4.sh
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh

```

RC: `0`
- OK: Fase 3 Terraform/GitOps offline evidenciada.
- OK: Fase 3 GitHub Actions offline evidenciada.

## 6. Segurança e segredos


### Scanner de segredos

```text
Arquivos escaneados: 197
OK: nenhum segredo real encontrado nos arquivos versionáveis relevantes.
OK: credenciais fake test/test da Fase 2 LocalStack foram tratadas como allowlist controlada.
OK: padrões de regex/scanner não foram tratados como segredos reais.

```

SCAN_RC: `0`

## 7. Declaração de prontidão para Fase 4


## Declaração de prontidão

Com base nos checkpoints e evidências versionadas:

- A Fase 2 local está funcional e revalidada.
- A Fase 3 cloud está funcional e revalidada.
- GitOps/ArgoCD está `Synced/Healthy`.
- Os pods dos 5 microsserviços estão `Running/Ready`.
- A cadeia SQS -> analytics-service -> DynamoDB foi validada após renovação das credenciais temporárias do AWS Academy.
- A correção de segurança da Fase 2 impede persistência de API key runtime no Compose.
- Não há segredo real detectado nos arquivos versionáveis relevantes deste gate.
- A Fase 4 será iniciada como entrega real, não como rebuild.


## 8. Resultado final


### Git status final do gate

```bash
$ git status --short
?? _shared/evidencias/gate-pre-fase4-fases2-3.md
?? _shared/scripts/21_gate_pre_fase4_fases2_3.sh

```

RC: `0`

### HEAD final

```bash
$ git log --oneline --decorate -5
e38cf8d (HEAD -> main, origin/main) fix: prevent phase 2 e2e from persisting runtime api key
d7666dd docs: record phase 2 local pre phase 4 revalidation
eab9b9d docs: record phase 3 pre phase 4 app validation
c597af1 docs: record phase 3 pre phase 4 checkpoint
9c2f944 docs: record phase 3 gitops cloud e2e validation

```

RC: `0`
