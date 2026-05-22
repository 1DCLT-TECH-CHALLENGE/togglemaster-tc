# Fase 3 - BLOCO 10 - Módulo RDS offline

Data: 2026-05-22

## Objetivo

Criar e conectar o módulo Terraform de RDS PostgreSQL da Fase 3, ainda sem conexão com AWS.

## Contexto

Na Fase 2 local, os serviços `auth-service`, `flag-service` e `targeting-service` usam PostgreSQL local em containers.

Na Fase 3, esses bancos serão modelados como RDS PostgreSQL via Terraform.

## Bancos modelados

- `auth_db` / `auth_user`
- `flags_db` / `flags_user`
- `targeting_db` / `targeting_user`

## Decisão de segurança

Não foi usado `db_password`.

O módulo usa:

- `manage_master_user_password = true`

Com isso, a senha do usuário master é gerenciada pelo RDS no AWS Secrets Manager.

## Ponto de atenção AWS Academy

Antes de `terraform plan/apply`, validar se a `LabRole` permite o uso de RDS com senha gerenciada no Secrets Manager.

Se o AWS Academy não permitir esse fluxo, será necessário documentar fallback seguro sem versionar segredo.

## Ambiente dev

O módulo `rds` foi conectado em:

- `terraform/environments/dev/main.tf`

Outputs adicionados em:

- `terraform/environments/dev/outputs.tf`

O output com ARNs de secrets é `sensitive`.

## Restrições respeitadas

Não foi executado:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- login no AWS Academy.

## Status

Módulo RDS criado e conectado ao ambiente `dev` para validação local posterior.
