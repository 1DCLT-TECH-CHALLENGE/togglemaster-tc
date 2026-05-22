# Fase 3 - BLOCO 04 - Conexão do módulo networking no ambiente dev

Data: 2026-05-22

## Objetivo

Conectar o módulo `networking` ao ambiente Terraform `dev`, ainda sem conexão com AWS.

## Correção aplicada

O módulo `networking` foi ajustado para calcular CIDRs de subnets dinamicamente com `cidrsubnet(...)` usando `count.index`, evitando listas fixas de apenas duas subnets.

## Arquivos alterados

- `terraform/modules/networking/main.tf`
- `terraform/environments/dev/main.tf`
- `terraform/environments/dev/outputs.tf`

## Restrições respeitadas

Não foi executado:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- login no AWS Academy.

## Status

Módulo `networking` conectado ao ambiente `dev` para validação local posterior.
