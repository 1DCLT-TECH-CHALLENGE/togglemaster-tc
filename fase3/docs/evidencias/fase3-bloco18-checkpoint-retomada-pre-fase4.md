# Fase 3 - BLOCO 18 - Checkpoint de Retomada Pré-Fase 4

Data: Sat May 23 01:28:43 PM -03 2026

## Objetivo

Validar, de forma read-only, se a base cloud da Fase 3 continua pronta para servir de fundação da Fase 4.

Este checkpoint valida:

- Git local.
- Credenciais AWS Academy carregadas.
- Identidade AWS.
- Região.
- Cluster EKS.
- Nodes.
- ArgoCD.
- Pods dos microsserviços.
- Services e Ingress.
- Recursos AWS principais: ECR, RDS, ElastiCache, SQS e DynamoDB.

Nenhum recurso AWS será criado, alterado ou destruído por este script.


## 1. Conferência de diretório e arquivos de referência


### Diretório raiz

```bash
$ pwd

```

RC: `0`

### Listagem raiz

```bash
$ ls -la /home/wellk/togglemaster-tc

```

RC: `0`
- Nota: `instrucoes-rebuild.txt` e `TOPOLOGIAS-FASES-1-3` são guias externos desta conversa/source, não artefatos obrigatórios do repositório local.

## 2. Git


### Git status

```bash
$ git status --short

```

RC: `0`

### Último commit

```bash
$ git log --oneline --decorate -5

```

RC: `0`

### Branch atual

```bash
$ git branch --show-current

```

RC: `0`

## 3. Ferramentas locais


### AWS CLI

```bash
$ aws --version

```

RC: `0`

### kubectl

```bash
$ kubectl version --client=true

```

RC: `0`

### Terraform

```bash
$ terraform version

```

RC: `0`

### Docker

```bash
$ docker --version

```

RC: `0`

## 4. AWS Academy / identidade

- Região usada: `us-east-1`.

### AWS STS get-caller-identity

```bash
$ aws sts get-caller-identity --output table

```

RC: `0`

## 5. Descoberta do cluster EKS


### Listar clusters EKS

```bash
$ aws eks list-clusters --region us-east-1 --output table

```

RC: `0`
- Cluster selecionado: `togglemaster-dev-eks`.

### Describe cluster EKS

```bash
$ aws eks describe-cluster --name togglemaster-dev-eks --region us-east-1 --query cluster.{name:name,status:status,endpoint:endpoint,version:version,roleArn:roleArn} --output table

```

RC: `0`

## 6. kubeconfig e Kubernetes


### Atualizar kubeconfig local

```bash
$ aws eks update-kubeconfig --name togglemaster-dev-eks --region us-east-1 --alias togglemaster-dev-eks

```

RC: `0`

### Contexto kubectl atual

```bash
$ kubectl config current-context

```

RC: `0`

### Nodes

```bash
$ kubectl get nodes -o wide

```

RC: `0`

### Namespaces principais

```bash
$ kubectl get ns

```

RC: `0`

## 7. ArgoCD e GitOps


### Applications ArgoCD

```bash
$ kubectl get applications -n argocd -o wide

```

RC: `0`

### Application togglemaster-dev

```bash
$ kubectl get application togglemaster-dev -n argocd -o wide

```

RC: `0`

## 8. Namespace togglemaster


### Pods togglemaster

```bash
$ kubectl get pods -n togglemaster -o wide

```

RC: `0`

### Deployments togglemaster

```bash
$ kubectl get deployments -n togglemaster -o wide

```

RC: `0`

### Services togglemaster

```bash
$ kubectl get svc -n togglemaster -o wide

```

RC: `0`

### Ingress togglemaster

```bash
$ kubectl get ingress -n togglemaster -o wide

```

RC: `0`

## 9. Recursos AWS principais


### ECR repositories ToggleMaster

```bash
$ aws ecr describe-repositories --region us-east-1 --query repositories[?contains(repositoryName, `togglemaster`) || contains(repositoryName, `auth`) || contains(repositoryName, `flag`) || contains(repositoryName, `targeting`) || contains(repositoryName, `evaluation`) || contains(repositoryName, `analytics`)].repositoryName --output table

```

RC: `0`

### RDS instances

```bash
$ aws rds describe-db-instances --region us-east-1 --query DBInstances[].{id:DBInstanceIdentifier,status:DBInstanceStatus,engine:Engine,endpoint:Endpoint.Address} --output table

```

RC: `0`

### ElastiCache clusters

```bash
$ aws elasticache describe-cache-clusters --region us-east-1 --show-cache-node-info --query CacheClusters[].{id:CacheClusterId,status:CacheClusterStatus,engine:Engine,node:CacheNodes[0].Endpoint.Address} --output table

```

RC: `0`

### SQS queues

```bash
$ aws sqs list-queues --region us-east-1 --output table

```

RC: `0`

### DynamoDB tables

```bash
$ aws dynamodb list-tables --region us-east-1 --output table

```

RC: `0`

## 10. Resultado do checkpoint


## Resultado

- ArgoCD: `Synced/Healthy`
- Pods no namespace `togglemaster`: sem pods não prontos detectados.
- Log completo: `/home/wellk/togglemaster-tc/fase3/logs/fase3-bloco18-checkpoint-retomada-pre-fase4.log`
