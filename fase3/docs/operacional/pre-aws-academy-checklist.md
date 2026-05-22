# Fase 3 - Checklist pré-AWS Academy

Data: 2026-05-22

## Objetivo

Definir o checklist obrigatório antes de abrir o AWS Academy Lab e antes de qualquer conexão real com AWS.

Este documento marca a fronteira entre:

- preparação offline/local;
- execução cloud real no AWS Academy.

## Estado esperado antes de abrir o Lab

Antes de abrir o AWS Academy, os seguintes itens devem estar concluídos:

- Fase 2 local fechada e versionada;
- Terraform da Fase 3 criado;
- módulos Terraform criados;
- GitOps criado;
- ArgoCD Application placeholder criado;
- script local de validação offline criado;
- workflows GitHub Actions offline criados;
- bootstrap offline da Fase 3 criado;
- auditoria de segredos executada;
- `.terraform/` fora do Git;
- `.terraform.lock.hcl` versionado;
- nenhum `terraform.tfstate` versionado;
- nenhum `terraform.tfvars` real versionado;
- nenhum `.env` real versionado;
- nenhum log/tmp versionado.

## Comandos permitidos antes do Lab

Permitidos offline:

- `terraform fmt -recursive -check`;
- `terraform init -backend=false`;
- `terraform validate`;
- `kubectl kustomize fase3/gitops/base`;
- `kubectl kustomize fase3/gitops/overlays/dev`;
- `kubectl kustomize fase3/gitops/apps`;
- `./fase3/local/scripts/01_validate_phase3_offline.sh`;
- `./bootstraps/03_bootstrap_fase3.sh`.

## Comandos proibidos antes do Lab

Não executar antes de abrir e configurar o AWS Academy Lab:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- `terraform destroy`;
- `kubectl apply`;
- `helm install`;
- `helm upgrade`;
- push de imagem para ECR real;
- deploy real em EKS.

## Regras AWS Academy

Quando chegar a etapa AWS Academy:

- usar apenas credenciais temporárias do Lab;
- não salvar credenciais no repositório;
- não commitar `~/.aws/credentials`;
- não commitar `terraform.tfvars` real;
- não commitar `backend.hcl` real se contiver nomes sensíveis do Lab;
- usar `LabRole`;
- não criar IAM Roles novas para EKS;
- não criar IAM Policies arbitrárias;
- validar se `LabRole` pode ser usada pelo EKS Cluster;
- validar se `LabRole` pode ser usada pelo Managed Node Group;
- validar disponibilidade de região, AZs, instâncias e versões.

## Pontos que devem ser validados ao abrir o Lab

Quando o AWS Academy for aberto, validar:

1. credenciais temporárias disponíveis;
2. região real do Lab;
3. existência da `LabRole`;
4. ARN da `LabRole`;
5. permissões da `LabRole`;
6. disponibilidade de EKS;
7. disponibilidade de RDS PostgreSQL;
8. disponibilidade de ElastiCache Redis;
9. disponibilidade de DynamoDB;
10. disponibilidade de SQS;
11. disponibilidade de ECR;
12. limites de VPC, subnets, Elastic IPs e NAT Gateway;
13. custo/limite do Lab;
14. possibilidade de usar Secrets Manager;
15. estratégia de backend Terraform.

## Primeiro comando AWS permitido

O primeiro comando AWS permitido deverá ser apenas de identificação, depois que o Lab estiver aberto e as credenciais temporárias estiverem carregadas:

    aws sts get-caller-identity

Esse comando ainda não deve ser executado antes da autorização explícita.

## Critério de parada

Ao chegar na etapa que exigir credenciais AWS reais, interromper o fluxo e registrar:

    A partir daqui precisa abrir o AWS Academy Lab.

## Status

Checklist pré-AWS Academy criado.
