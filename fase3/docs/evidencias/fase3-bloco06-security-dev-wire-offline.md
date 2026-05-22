# Fase 3 - BLOCO 06 - Conexão do módulo security no ambiente dev

Data: 2026-05-22

## Objetivo

Conectar o módulo `security` ao ambiente Terraform `dev`, ainda sem conexão com AWS.

## Módulos envolvidos

- `networking`
- `security`

## Dependências

O módulo `security` recebe:

- `vpc_id` a partir de `module.networking.vpc_id`;
- `vpc_cidr_block` a partir de `module.networking.vpc_cidr_block`;
- `name_prefix` a partir de `local.name_prefix`;
- `tags` a partir de `var.tags`.

## Outputs adicionados

- `alb_security_group_id`
- `eks_cluster_additional_security_group_id`
- `eks_nodes_security_group_id`
- `rds_security_group_id`
- `redis_security_group_id`

## Restrições respeitadas

Não foi executado:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- login no AWS Academy.

## Status

Módulo `security` conectado ao ambiente `dev` para validação local posterior.
