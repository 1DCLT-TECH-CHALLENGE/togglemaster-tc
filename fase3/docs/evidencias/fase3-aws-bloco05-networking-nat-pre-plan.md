# Fase 3 - AWS Academy - BLOCO AWS-05 - Ajuste de networking pré-plan

Data: 2026-05-22

## Objetivo

Corrigir o módulo Terraform de networking antes do primeiro `terraform plan`, alinhando-o à topologia da Fase 3.

## Topologia de referência

A topologia da Fase 3 usa:

- VPC própria `10.10.0.0/16`;
- 2 subnets públicas:
  - `10.10.0.0/20`;
  - `10.10.16.0/20`;
- 2 subnets privadas:
  - `10.10.32.0/20`;
  - `10.10.48.0/20`;
- ALB/Ingress nas subnets públicas;
- EKS/nodes nas subnets privadas;
- RDS nas subnets privadas;
- serviços gerenciados AWS como SQS, DynamoDB e Secrets Manager.

## Problema identificado

O módulo `networking` criava subnets, mas usando cálculo `/24`, divergente da topologia `/20`.

Além disso, o módulo criava subnets privadas sem NAT Gateway e sem rota default para saída.

## Correções aplicadas

Foram adicionados/ajustados:

- `subnet_newbits`;
- `public_subnet_offset`;
- `private_subnet_offset`;
- `enable_nat_gateway`;
- `single_nat_gateway`;
- cálculo CIDR de subnets públicas e privadas em `/20`;
- `aws_eip.nat`;
- `aws_nat_gateway.this`;
- `aws_route.private_default_nat`;
- outputs de NAT Gateway e EIP.

## Decisão para AWS Academy

A arquitetura completa suporta NAT por AZ com:

- `single_nat_gateway = false`

Para o ambiente `dev` no AWS Academy, será usado:

- `single_nat_gateway = true`

Essa decisão reduz custo, tempo de criação e consumo de quota do Lab, mantendo conectividade real para as subnets privadas.

## O que NÃO foi executado

Não foi executado:

- `terraform plan`;
- `terraform apply`;
- criação de recurso AWS.

## Status

Networking ajustado antes do primeiro `terraform plan`.
