# Fase 3 - ToggleMaster TC

## Objetivo

Reconstruir a infraestrutura cloud real do ToggleMaster usando IaC, DevSecOps e GitOps.

A Fase 3 é a primeira fase do rebuild que usará AWS real.

## Ambiente alvo

AWS Academy Lab.

## Regra principal AWS Academy

Usar obrigatoriamente a `LabRole`.

No AWS Academy:

- Terraform não deve criar IAM Roles novas para EKS;
- Terraform não deve criar IAM Policies arbitrárias;
- EKS Cluster Role deve usar `LabRole`;
- EKS Managed Node Group Role deve usar `LabRole`;
- credenciais temporárias não devem ser salvas no Git;
- `terraform.tfstate` não deve ser local nem versionado;
- `terraform.tfvars` real não deve ser versionado.

## Escopo técnico

A Fase 3 deve preparar/provisionar:

- VPC;
- subnets públicas e privadas;
- route tables;
- security groups;
- EKS;
- Managed Node Groups;
- ECR para os 5 microsserviços;
- 3 RDS PostgreSQL;
- ElastiCache Redis;
- SQS;
- DynamoDB;
- estratégia de Secrets Manager ou fallback seguro;
- manifests Kubernetes/GitOps;
- ArgoCD;
- workflows DevSecOps.

## O que pode ser feito offline

Antes de conectar no AWS Academy:

- criar estrutura Terraform;
- criar módulos;
- criar arquivos `.example`;
- criar manifests GitOps;
- criar workflows;
- rodar validações locais;
- documentar ADRs;
- preparar scripts.

## O que NÃO será feito offline

- `aws configure`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- push de imagem para ECR real;
- deploy em EKS real.

## Evidências

- `docs/evidencias/fase3-bloco01-fundacao-offline.md`

## Próximo passo

Criar a base Terraform local com módulos e ambiente `dev`, ainda sem conectar na AWS.

<!-- TOGGLEMASTER_FINAL_NAV_START -->
## Reprodutibilidade da Fase 3

Escopo: infraestrutura cloud via Terraform/IaC usando a base dos microsserviços da Fase 2.

Gerar plano sem aplicar recursos AWS:

`./bootstraps/03_bootstrap_fase3.sh`

Aplicar recursos AWS de forma controlada:

`CONFIRM_AWS_COSTS=SIM ./bootstraps/03_bootstrap_fase3.sh`

Destroy pós-entrega:

`CONFIRM_DESTROY=SIM ./bootstraps/06_destroy_aws_resources.sh`
<!-- TOGGLEMASTER_FINAL_NAV_END -->
