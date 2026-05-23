# Fase 4 - BLOCO 25 - Plano de Correção de Capacidade para Observabilidade

Data: Sat May 23 03:00:03 PM -03 2026

## Objetivo

Planejar a correção definitiva de capacidade do EKS antes da instalação da stack de observabilidade da Fase 4.

Este bloco é read-only do ponto de vista de infraestrutura:

- não executa `terraform apply`;
- não altera recursos AWS;
- não instala Prometheus, Grafana, Loki ou OTel;
- apenas calcula opções e registra a decisão técnica.


## 1. Estado Git


### Git status

```bash
$ git status --short
?? fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md
?? fase4/scripts/25_plan_observability_capacity_fix.sh

```

RC: `0`

### Últimos commits

```bash
$ git log --oneline --decorate -8
7d6f15d (HEAD -> main, origin/main) docs: record phase 4 observability capacity gate
4680d8b docs: record phase 4 stack inventory
74f1c33 docs: open phase 4 delivery
0d26f9f docs: add pre phase 4 readiness gate
e38cf8d fix: prevent phase 2 e2e from persisting runtime api key
d7666dd docs: record phase 2 local pre phase 4 revalidation
eab9b9d docs: record phase 3 pre phase 4 app validation
c597af1 docs: record phase 3 pre phase 4 checkpoint

```

RC: `0`
- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 25.

## 2. Base confirmada do BLOCO 24


### Resumo do gate de capacidade anterior

```bash
$ bash -lc grep -E 'CAPACITY_GATE=|TOTAL_PODS_REMAINING=|REQUIRED_TOTAL_FREE_PODS=|RESULT_RC=' fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log 2>/dev/null | tail -30 || true
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:TOTAL_PODS_REMAINING=0
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:- REQUIRED_TOTAL_FREE_PODS=14
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:CAPACITY_GATE=FAIL
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:TOTAL_PODS_REMAINING=0
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:- REQUIRED_TOTAL_FREE_PODS=14
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:CAPACITY_GATE=FAIL
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:TOTAL_PODS_REMAINING=0
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:- REQUIRED_TOTAL_FREE_PODS=14
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:CAPACITY_GATE=FAIL
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:CAPACITY_GATE=FAIL
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:TOTAL_PODS_REMAINING=0
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:REQUIRED_TOTAL_FREE_PODS=14
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:CAPACITY_GATE=FAIL
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.log:RESULT_RC=24

```

RC: `0`

## 3. Estado atual read-only do EKS


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

### Describe nodegroup atual

```bash
$ aws eks describe-nodegroup --cluster-name togglemaster-dev-eks --nodegroup-name togglemaster-dev-default-ng --region us-east-1 --query nodegroup.{nodegroupName:nodegroupName,status:status,instanceTypes:instanceTypes,scalingConfig:scalingConfig,capacityType:capacityType,amiType:amiType} --output table
--------------------------------------------------
|                DescribeNodegroup               |
+----------------+-------------------------------+
|  amiType       |  AL2023_x86_64_STANDARD       |
|  capacityType  |  ON_DEMAND                    |
|  nodegroupName |  togglemaster-dev-default-ng  |
|  status        |  ACTIVE                       |
+----------------+-------------------------------+
||                 instanceTypes                ||
|+----------------------------------------------+|
||  t3.small                                    ||
|+----------------------------------------------+|
||                 scalingConfig                ||
|+----------------------------------+-----------+|
||  desiredSize                     |  2        ||
||  maxSize                         |  3        ||
||  minSize                         |  1        ||
|+----------------------------------+-----------+|

```

RC: `0`

### Nodes atuais

```bash
$ kubectl get nodes -o wide
NAME                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-40-95.ec2.internal    Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.40.95    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-49-137.ec2.internal   Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.49.137   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown

```

RC: `0`

### Pods atuais

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
togglemaster   analytics-service-6946467b6b-9fvmm                  1/1     Running   0          48m   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   auth-service-584688f79d-vpg2z                       1/1     Running   0          11h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   auth-service-584688f79d-xt6v8                       1/1     Running   0          11h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   evaluation-service-7949b95dd5-kf2md                 1/1     Running   0          48m   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   evaluation-service-7949b95dd5-wbrlc                 1/1     Running   0          47m   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   flag-service-7cd69f6bf9-9ffxm                       1/1     Running   0          11h   10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   flag-service-7cd69f6bf9-x7pxc                       1/1     Running   0          11h   10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   targeting-service-66d4bb78b6-7zc9d                  1/1     Running   0          11h   10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   targeting-service-66d4bb78b6-8tw7t                  1/1     Running   0          11h   10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>

```

RC: `0`

## 4. Inspeção IaC atual


### Terraform EKS variables e module references

```bash
$ bash -lc grep -RInE --exclude='*.tfstate' --exclude='*.tfstate.backup' --exclude='*.tfvars' --exclude='*.auto.tfvars' 'node_instance_types|node_desired_size|node_min_size|node_max_size|desired_size|min_size|max_size|instance_types' fase3/terraform/modules/eks fase3/terraform/environments/dev || true
fase3/terraform/modules/eks/variables.tf:45:variable "node_instance_types" {
fase3/terraform/modules/eks/variables.tf:51:variable "node_desired_size" {
fase3/terraform/modules/eks/variables.tf:57:variable "node_min_size" {
fase3/terraform/modules/eks/variables.tf:63:variable "node_max_size" {
fase3/terraform/modules/eks/main.tf:103:  instance_types = var.node_instance_types
fase3/terraform/modules/eks/main.tf:105:    desired_size = var.node_desired_size
fase3/terraform/modules/eks/main.tf:106:    min_size     = var.node_min_size
fase3/terraform/modules/eks/main.tf:107:    max_size     = var.node_max_size

```

RC: `0`

### Arquivos Terraform versionados relevantes

```bash
$ bash -lc find fase3/terraform/modules/eks fase3/terraform/environments/dev -maxdepth 2 -type f \( -name '*.tf' -o -name '*.tfvars.example' \) | sort
fase3/terraform/environments/dev/main.tf
fase3/terraform/environments/dev/outputs.tf
fase3/terraform/environments/dev/providers.tf
fase3/terraform/environments/dev/terraform.tfvars.example
fase3/terraform/environments/dev/variables.tf
fase3/terraform/environments/dev/versions.tf
fase3/terraform/modules/eks/main.tf
fase3/terraform/modules/eks/outputs.tf
fase3/terraform/modules/eks/variables.tf

```

RC: `0`

### Check tfstate/tfvars versionados

```bash
$ bash -lc git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true

```

RC: `0`

## 5. Cálculo de opções de capacidade


### Cálculo de opções de capacidade

```text
Estado atual:
- CURRENT_NODE_COUNT=2
- CURRENT_PER_NODE_POD_CAPACITY=11
- CURRENT_TOTAL_POD_CAPACITY=22
- CURRENT_TOTAL_PODS_USED=22
- CURRENT_TOTAL_PODS_REMAINING=0
- EXISTING_DAEMONSETS_PER_NODE=2
- EXISTING_NON_DAEMONSET_PODS=18

DaemonSets existentes detectados:
- kube-system/aws-node: desired=2
- kube-system/kube-proxy: desired=2

Premissas para observabilidade:
- OBSERVABILITY_DAEMONSETS_PER_NODE=2
- OBSERVABILITY_SINGLETON_PODS=7
- BUFFER_PODS=3

Cenários calculados mantendo o mesmo pod.capacity por node:
nodes,total_capacity,estimated_existing_pods_after_scale,estimated_free_before_observability,required_observability_plus_buffer,estimated_free_after_observability,decision
3,33,24,9,16,-7,FAIL
4,44,26,18,18,0,PASS_LOW_MARGIN
5,55,28,27,20,7,PASS
6,66,30,36,22,14,PASS

RECOMMENDED_NODE_DESIRED_SIZE=5
RECOMMENDED_NODE_MIN_SIZE=2
RECOMMENDED_NODE_MAX_SIZE=5
RECOMMENDED_INSTANCE_TYPE=t3.small
RECOMMENDATION_REASON=Menor alteração possível: manter instance type atual e ampliar quantidade de nodes via IaC.

```

## 6. Decisão técnica


## Decisão técnica

A decisão proposta para o próximo bloco é alterar a capacidade do node group via IaC, sem trocar o tipo de instância inicialmente.

Valores recomendados:

- `node_min_size = 2`
- `node_desired_size = 5`
- `node_max_size = 5`
- `node_instance_types = ["t3.small"]`

ADR gerada:

- `fase4/docs/adr/ADR-003-fase4-correcao-capacidade-observabilidade.md`


## 7. Resultado


## Resultado

BLOCO 25 concluído com sucesso.

Próximo bloco recomendado:

1. alterar Terraform para refletir a decisão;
2. rodar `terraform fmt` e `terraform validate`;
3. gerar `terraform plan`;
4. revisar o plano antes de qualquer apply.

