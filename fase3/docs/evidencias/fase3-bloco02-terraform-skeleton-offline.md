# Fase 3 - BLOCO 02 - Terraform skeleton offline

Data: 2026-05-22

## Objetivo

Criar a base inicial do Terraform para a Fase 3, ainda sem conexão com AWS.

## Arquivos criados

- `terraform/README.md`
- `terraform/environments/dev/versions.tf`
- `terraform/environments/dev/providers.tf`
- `terraform/environments/dev/variables.tf`
- `terraform/environments/dev/main.tf`
- `terraform/environments/dev/outputs.tf`
- `terraform/environments/dev/backend.example.hcl`
- `terraform/environments/dev/terraform.tfvars.example`

## Restrições respeitadas

- Nenhuma credencial AWS foi criada.
- Nenhuma credencial AWS foi versionada.
- Nenhum `terraform.tfvars` real foi criado.
- Nenhum `backend.hcl` real foi criado.
- Nenhum `terraform.tfstate` foi criado.
- Nenhum `terraform plan` foi executado.
- Nenhum `terraform apply` foi executado.
- Nenhum recurso AWS foi criado.
- AWS Academy ainda não foi acessado.

## Decisão importante

O nome da role do AWS Academy foi parametrizado como `lab_role_name`, com default `LabRole`.

Essa variável será usada pelos módulos que precisarem referenciar a IAM Role existente do Academy, especialmente EKS e Managed Node Groups.
