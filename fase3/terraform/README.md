# Terraform - Fase 3

## Objetivo

Preparar a infraestrutura AWS da Fase 3 do ToggleMaster via Terraform.

## Ambiente alvo

AWS Academy Lab.

## Regras obrigatórias

- Usar `LabRole`.
- Não criar IAM Roles novas para EKS.
- Não criar IAM Policies arbitrárias.
- Não versionar `terraform.tfvars` real.
- Não versionar `terraform.tfstate`.
- Não versionar `backend.hcl` real.
- Não executar `terraform plan` ou `terraform apply` antes do AWS Academy Lab estar aberto.

## Ambiente dev

Diretório:

    terraform/environments/dev

Arquivos criados no BLOCO 02:

- `versions.tf`
- `providers.tf`
- `variables.tf`
- `main.tf`
- `outputs.tf`
- `backend.example.hcl`
- `terraform.tfvars.example`

## Validação offline permitida

Permitido posteriormente:

    terraform fmt -recursive
    terraform init -backend=false
    terraform validate

Não permitido ainda:

    terraform plan
    terraform apply
