# Fase 4 - BLOCO 24 - Gate de Capacidade para Observabilidade

Data: Sat May 23 02:57:14 PM -03 2026

## Objetivo

Avaliar se o cluster EKS atual comporta a stack de observabilidade da Fase 4 antes de instalar qualquer componente.

Este bloco é read-only e não altera infraestrutura.


## 1. Estado Git


### Git status

```bash
$ git status --short
?? fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md
?? fase4/scripts/24_capacity_gate_observability.sh

```

RC: `0`

### Últimos commits

```bash
$ git log --oneline --decorate -8
4680d8b (HEAD -> main, origin/main) docs: record phase 4 stack inventory
74f1c33 docs: open phase 4 delivery
0d26f9f docs: add pre phase 4 readiness gate
e38cf8d fix: prevent phase 2 e2e from persisting runtime api key
d7666dd docs: record phase 2 local pre phase 4 revalidation
eab9b9d docs: record phase 3 pre phase 4 app validation
c597af1 docs: record phase 3 pre phase 4 checkpoint
9c2f944 docs: record phase 3 gitops cloud e2e validation

```

RC: `0`
- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 24.

## 2. Estado atual do cluster


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

### Nodes

```bash
$ kubectl get nodes -o wide
NAME                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-40-95.ec2.internal    Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.40.95    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-49-137.ec2.internal   Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.49.137   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown

```

RC: `0`

### Namespaces

```bash
$ kubectl get ns
NAME              STATUS   AGE
argocd            Active   13h
default           Active   18h
kube-node-lease   Active   18h
kube-public       Active   18h
kube-system       Active   18h
togglemaster      Active   14h

```

RC: `0`

### ArgoCD application

```bash
$ kubectl get application togglemaster-dev -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         4680d8b677fc9677a7da81c1cb3ab369cfccdda4   default

```

RC: `0`

### Pods por namespace

```bash
$ kubectl get pods -A -o wide
NAMESPACE      NAME                                                READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
argocd         argocd-application-controller-0                     1/1     Running   0          11h   10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-applicationset-controller-5b964db9cd-rl8kn   1/1     Running   0          11h   10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-dex-server-b8cc6d795-r658p                   1/1     Running   0          11h   10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-notifications-controller-597cccd4ff-q2p2l    1/1     Running   0          11h   10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-redis-675f9c4c99-ngqb4                       1/1     Running   0          11h   10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd         argocd-repo-server-5c46694888-b4bqj                 1/1     Running   0          11h   10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd         argocd-server-7f66865588-df8sl                      1/1     Running   0          11h   10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system    aws-node-4tqtk                                      2/2     Running   0          11h   10.10.40.95    ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    aws-node-hxr94                                      2/2     Running   0          11h   10.10.49.137   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system    coredns-849f74687b-lg2g2                            1/1     Running   0          11h   10.10.45.165   ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    coredns-849f74687b-sqcpd                            1/1     Running   0          11h   10.10.41.233   ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    kube-proxy-57stg                                    1/1     Running   0          11h   10.10.40.95    ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    kube-proxy-fm6l2                                    1/1     Running   0          11h   10.10.49.137   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   analytics-service-6946467b6b-9fvmm                  1/1     Running   0          45m   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   auth-service-584688f79d-vpg2z                       1/1     Running   0          11h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   auth-service-584688f79d-xt6v8                       1/1     Running   0          11h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   evaluation-service-7949b95dd5-kf2md                 1/1     Running   0          45m   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   evaluation-service-7949b95dd5-wbrlc                 1/1     Running   0          44m   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   flag-service-7cd69f6bf9-9ffxm                       1/1     Running   0          11h   10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   flag-service-7cd69f6bf9-x7pxc                       1/1     Running   0          11h   10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   targeting-service-66d4bb78b6-7zc9d                  1/1     Running   0          11h   10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   targeting-service-66d4bb78b6-8tw7t                  1/1     Running   0          11h   10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>

```

RC: `0`

### Deployments togglemaster

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

### Services togglemaster

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

### Resultado Kubernetes/GitOps

- ArgoCD: `Synced/Healthy`
- Pods não prontos no namespace `togglemaster`: nenhum.

## 3. Capacidade e consumo de pods


### Relatório de capacidade de pods

```text
Resumo por node:
- ip-10-10-40-95.ec2.internal
  allocatable.cpu=1930m
  allocatable.memory=1471796Ki
  pod.capacity=11
  pod.used=11
  pod.remaining=0
- ip-10-10-49-137.ec2.internal
  allocatable.cpu=1930m
  allocatable.memory=1471792Ki
  pod.capacity=11
  pod.used=11
  pod.remaining=0

Resumo por namespace:
- argocd: 7 pods
- kube-system: 6 pods
- togglemaster: 9 pods

TOTAL_POD_CAPACITY=22
TOTAL_PODS_USED=22
TOTAL_PODS_REMAINING=0

Estimativa conservadora para observabilidade base:
- ESTIMATED_DAEMONSET_PODS=4
- ESTIMATED_SINGLETON_PODS=6
- ESTIMATED_OTEL_PODS=1
- ESTIMATED_OBSERVABILITY_PODS=11
- REQUIRED_BUFFER_PODS=3
- REQUIRED_TOTAL_FREE_PODS=14
CAPACITY_GATE=FAIL
DECISION=Cluster não tem folga suficiente de pods para instalar stack completa com segurança.

```

## 4. Requests e limits atuais


### Top nodes se metrics-server existir

```bash
$ bash -lc kubectl top nodes 2>/dev/null || true

```

RC: `0`

### Top pods se metrics-server existir

```bash
$ bash -lc kubectl top pods -A 2>/dev/null || true

```

RC: `0`

### Requests/limits dos pods por namespace

```bash
$ bash -lc kubectl describe nodes | sed -n '/Allocated resources:/,/Events:/p' | head -220
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                350m (18%)  0 (0%)
  memory             140Mi (9%)  340Mi (23%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-1Gi      0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
Events:              <none>
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests   Limits
  --------           --------   ------
  cpu                150m (7%)  0 (0%)
  memory             0 (0%)     0 (0%)
  ephemeral-storage  0 (0%)     0 (0%)
  hugepages-1Gi      0 (0%)     0 (0%)
  hugepages-2Mi      0 (0%)     0 (0%)
Events:              <none>

```

RC: `0`

## 5. Node group e Terraform


### EKS nodegroups

```bash
$ aws eks list-nodegroups --cluster-name togglemaster-dev-eks --region us-east-1 --output table
-----------------------------------
|         ListNodegroups          |
+---------------------------------+
||          nodegroups           ||
|+-------------------------------+|
||  togglemaster-dev-default-ng  ||
|+-------------------------------+|

```

RC: `0`

### Describe nodegroup togglemaster-dev-default-ng

```bash
$ aws eks describe-nodegroup --cluster-name togglemaster-dev-eks --nodegroup-name togglemaster-dev-default-ng --region us-east-1 --query nodegroup.{nodegroupName:nodegroupName,status:status,instanceTypes:instanceTypes,scalingConfig:scalingConfig,capacityType:capacityType} --output table
-----------------------------------------------------------
|                    DescribeNodegroup                    |
+---------------+-------------------------------+---------+
| capacityType  |         nodegroupName         | status  |
+---------------+-------------------------------+---------+
|  ON_DEMAND    |  togglemaster-dev-default-ng  |  ACTIVE |
+---------------+-------------------------------+---------+
||                     instanceTypes                     ||
|+-------------------------------------------------------+|
||  t3.small                                             ||
|+-------------------------------------------------------+|
||                     scalingConfig                     ||
|+---------------------+----------------+----------------+|
||     desiredSize     |    maxSize     |    minSize     ||
|+---------------------+----------------+----------------+|
||  2                  |  3             |  1             ||
|+---------------------+----------------+----------------+|

```

RC: `0`

### Terraform EKS module

```bash
$ bash -lc grep -RInE --exclude='*.tfstate' --exclude='*.tfstate.backup' --exclude='*.tfvars' --exclude='*.auto.tfvars' 'desired_size|min_size|max_size|instance_types|t3|node_group|node_group_desired' fase3/terraform/modules/eks fase3/terraform/environments/dev || true
fase3/terraform/modules/eks/variables.tf:45:variable "node_instance_types" {
fase3/terraform/modules/eks/variables.tf:48:  default     = ["t3.small"]
fase3/terraform/modules/eks/variables.tf:51:variable "node_desired_size" {
fase3/terraform/modules/eks/variables.tf:57:variable "node_min_size" {
fase3/terraform/modules/eks/variables.tf:63:variable "node_max_size" {
fase3/terraform/modules/eks/main.tf:90:resource "aws_eks_node_group" "default" {
fase3/terraform/modules/eks/main.tf:99:  node_group_name = "${var.name_prefix}-default-ng"
fase3/terraform/modules/eks/main.tf:103:  instance_types = var.node_instance_types
fase3/terraform/modules/eks/main.tf:105:    desired_size = var.node_desired_size
fase3/terraform/modules/eks/main.tf:106:    min_size     = var.node_min_size
fase3/terraform/modules/eks/main.tf:107:    max_size     = var.node_max_size
fase3/terraform/modules/eks/outputs.tf:22:output "node_group_name" {
fase3/terraform/modules/eks/outputs.tf:24:  value       = aws_eks_node_group.default.node_group_name
fase3/terraform/environments/dev/outputs.tf:157:output "eks_node_group_name" {
fase3/terraform/environments/dev/outputs.tf:159:  value       = module.eks.node_group_name

```

RC: `0`

### Terraform state/tfvars tracking check

```bash
$ bash -lc git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true

```

RC: `0`
- OK: nenhum tfstate/tfvars real está versionado.

## 6. Decisão do gate


## Decisão do gate

- CAPACITY_GATE: `FAIL`
- Pods livres atuais: `0`
- Pods livres recomendados para instalação segura: `14`


### Decisão

O cluster **não** aparenta ter folga suficiente para instalar a stack completa de observabilidade com segurança.

Antes de instalar Prometheus/Grafana/Loki/OTel, deve ser feita uma correção definitiva de capacidade, preferencialmente uma das opções:

1. aumentar o node group para 3 nodes, se o AWS Academy permitir;
2. ajustar instance type para uma opção com mais memória/pods, se permitido;
3. reduzir agressivamente a stack, instalando componentes mínimos em sequência, somente se a ampliação não for possível.

A recomendação técnica é não instalar observabilidade completa enquanto este gate estiver em FAIL.


## 7. Resultado


## Resultado

- Gate de capacidade executado.
- Resultado: `FAIL`
- Log: `fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log`

