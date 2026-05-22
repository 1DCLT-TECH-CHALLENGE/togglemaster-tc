# Fase 3 - BLOCO 03 - Módulo networking offline

Data: 2026-05-22

## Objetivo

Criar o módulo Terraform de rede da Fase 3, ainda sem conexão com AWS.

## Recursos modelados

- VPC;
- Internet Gateway;
- subnets públicas;
- subnets privadas;
- route table pública;
- route tables privadas;
- associações de route table;
- tags compatíveis com Load Balancers Kubernetes.

## Observações

Este bloco apenas cria código Terraform.

Não executa:

- `aws configure`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- login no AWS Academy.

## Arquivos criados

- `terraform/modules/networking/variables.tf`
- `terraform/modules/networking/main.tf`
- `terraform/modules/networking/outputs.tf`

## Status

Módulo networking criado para validação local posterior.
