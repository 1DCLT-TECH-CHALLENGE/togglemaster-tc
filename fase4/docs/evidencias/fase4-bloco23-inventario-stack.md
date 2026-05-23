# Fase 4 - BLOCO 23 - Inventário Técnico e Decisão Inicial da Stack

Data: Sat May 23 02:47:53 PM -03 2026

## Objetivo

Inventariar o estado atual da base Fase 3/Fase 4 antes de instalar qualquer componente de observabilidade.

Este bloco é read-only e não altera infraestrutura.


## 1. Estado Git


### Git status

```bash
$ git status --short
?? fase4/docs/adr/ADR-002-fase4-stack-observabilidade-apm-incidentes.md
?? fase4/docs/evidencias/fase4-bloco23-inventario-stack.md
?? fase4/scripts/

```

RC: `0`

### Últimos commits

```bash
$ git log --oneline --decorate -8
74f1c33 (HEAD -> main, origin/main) docs: open phase 4 delivery
0d26f9f docs: add pre phase 4 readiness gate
e38cf8d fix: prevent phase 2 e2e from persisting runtime api key
d7666dd docs: record phase 2 local pre phase 4 revalidation
eab9b9d docs: record phase 3 pre phase 4 app validation
c597af1 docs: record phase 3 pre phase 4 checkpoint
9c2f944 docs: record phase 3 gitops cloud e2e validation
621563e fix: avoid extra pods during rolling updates

```

RC: `0`

### Branch atual

```bash
$ git branch --show-current
main

```

RC: `0`
- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 23.

## 2. Ferramentas locais


### AWS CLI

```bash
$ aws --version
aws-cli/2.34.49 Python/3.14.4 Linux/7.0.0-15-generic exe/x86_64.ubuntu.26

```

RC: `0`

### kubectl version client

```bash
$ kubectl version --client=true
Client Version: v1.30.14
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3

```

RC: `0`

### Helm version

```bash
$ helm version
version.BuildInfo{Version:"v3.20.0", GitCommit:"b2e4314fa0f229a1de7b4c981273f61d69ee5a59", GitTreeState:"clean", GoVersion:"go1.25.6"}

```

RC: `0`

### Docker version

```bash
$ docker --version
Docker version 29.5.1, build 2518b52

```

RC: `0`

### Docker compose version

```bash
$ docker compose version
Docker Compose version v5.1.3

```

RC: `0`

## 3. Estado AWS/EKS read-only


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

### EKS clusters

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

### kubectl current context

```bash
$ kubectl config current-context
togglemaster-dev-eks

```

RC: `0`

### Nodes

```bash
$ kubectl get nodes -o wide
NAME                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-40-95.ec2.internal    Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.40.95    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-49-137.ec2.internal   Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.49.137   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown

```

RC: `0`

### Node capacity allocatable

```bash
$ bash -lc kubectl describe nodes | grep -E 'Name:|cpu:|memory:|pods:' | head -120
Name:               ip-10-10-40-95.ec2.internal
  cpu:                2
  memory:             1959220Ki
  pods:               11
  cpu:                1930m
  memory:             1471796Ki
  pods:               11
Name:               ip-10-10-49-137.ec2.internal
  cpu:                2
  memory:             1959216Ki
  pods:               11
  cpu:                1930m
  memory:             1471792Ki
  pods:               11

```

RC: `0`

## 4. Estado Kubernetes e GitOps


### Namespaces

```bash
$ kubectl get ns
NAME              STATUS   AGE
argocd            Active   13h
default           Active   18h
kube-node-lease   Active   18h
kube-public       Active   18h
kube-system       Active   18h
togglemaster      Active   13h

```

RC: `0`

### ArgoCD applications

```bash
$ kubectl get applications -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         74f1c337635bc675f436d9d28505aac42c48ef09   default

```

RC: `0`

### Pods namespace togglemaster

```bash
$ kubectl get pods -n togglemaster -o wide
NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
analytics-service-6946467b6b-9fvmm    1/1     Running   0          36m   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
auth-service-584688f79d-vpg2z         1/1     Running   0          11h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
auth-service-584688f79d-xt6v8         1/1     Running   0          11h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
evaluation-service-7949b95dd5-kf2md   1/1     Running   0          36m   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
evaluation-service-7949b95dd5-wbrlc   1/1     Running   0          35m   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
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

### Deployments namespace togglemaster

```bash
$ kubectl get deployments -n togglemaster -o wide
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS           IMAGES                                                                                     SELECTOR
analytics-service    1/1     1            1           13h   analytics-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb    app.kubernetes.io/name=analytics-service
auth-service         2/2     2            2           13h   auth-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb         app.kubernetes.io/name=auth-service
evaluation-service   2/2     2            2           13h   evaluation-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb   app.kubernetes.io/name=evaluation-service
flag-service         2/2     2            2           13h   flag-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb         app.kubernetes.io/name=flag-service
targeting-service    2/2     2            2           13h   targeting-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb    app.kubernetes.io/name=targeting-service

```

RC: `0`

### Resultado Kubernetes/GitOps

- ArgoCD: `Synced/Healthy`
- Pods não prontos: nenhum.

## 5. Verificar se já existe observabilidade instalada


### Namespaces de observabilidade existentes

```bash
$ bash -lc kubectl get ns | grep -Ei 'monitor|observ|grafana|prometheus|loki|tempo|otel|datadog|newrelic' || true

```

RC: `0`

### Pods de observabilidade em todos namespaces

```bash
$ bash -lc kubectl get pods -A | grep -Ei 'prometheus|grafana|loki|tempo|otel|collector|alloy|datadog|newrelic' || true

```

RC: `0`

### Helm releases em todos namespaces

```bash
$ helm list -A
NAME	NAMESPACE	REVISION	UPDATED	STATUS	CHART	APP VERSION

```

RC: `0`

## 6. Estrutura GitOps e Fase 4


### Estrutura fase4

```bash
$ find fase4 -maxdepth 4 -type f
fase4/README.md
fase4/tmp/bloco23/last.out
fase4/scripts/23_inventory_phase4_stack.sh
fase4/docs/fase4-matriz-requisitos.md
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md
fase4/docs/evidencias/fase4-bloco23-inventario-stack.log
fase4/docs/evidencias/fase4-bloco22-abertura.md
fase4/docs/adr/ADR-001-fase4-estrategia-observabilidade.md
fase4/docs/adr/ADR-002-fase4-stack-observabilidade-apm-incidentes.md

```

RC: `0`

### GitOps fase3 atual

```bash
$ find fase3/gitops -maxdepth 5 -type f
fase3/gitops/apps/togglemaster-dev-application.yaml
fase3/gitops/apps/kustomization.yaml
fase3/gitops/overlays/dev/kustomization.yaml
fase3/gitops/base/configmap.yaml
fase3/gitops/base/auth-service.yaml
fase3/gitops/base/targeting-service.yaml
fase3/gitops/base/evaluation-service.yaml
fase3/gitops/base/namespace.yaml
fase3/gitops/base/analytics-service.yaml
fase3/gitops/base/flag-service.yaml
fase3/gitops/base/kustomization.yaml

```

RC: `0`

### Workflows atuais

```bash
$ find .github/workflows -maxdepth 1 -type f
.github/workflows/phase3-terraform-validate.yml
.github/workflows/phase3-security-scan.yml
.github/workflows/phase3-gitops-validate.yml

```

RC: `0`

## 7. Decisão inicial da stack


## Decisão inicial registrada

Foi criada a ADR:

- `fase4/docs/adr/ADR-002-fase4-stack-observabilidade-apm-incidentes.md`

Resumo:

- Prometheus/Grafana/Loki/OTel Collector serão a stack base.
- APM ainda pendente entre Datadog/New Relic.
- Incidentes ainda pendente entre PagerDuty/OpsGenie.
- ChatOps ainda pendente entre Discord/Slack/Teams.
- Self-healing será implementado com automação segura e demonstrável.


## 8. Resultado


## Resultado

Inventário técnico concluído.

Nenhuma infraestrutura foi alterada.

Próximo passo recomendado:

1. Criar manifests/Helm values da stack open source de observabilidade.
2. Aplicar via GitOps/ArgoCD.
3. Validar Prometheus, Grafana, Loki e OTel Collector antes de APM externo.

