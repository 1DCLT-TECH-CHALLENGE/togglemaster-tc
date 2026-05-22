# Fase 3 - AWS Academy - BLOCO AWS-04 - Inventário read-only EC2/VPC

Data: 2026-05-22

## Objetivo

Registrar inventário inicial read-only de rede no AWS Academy Lab antes de qualquer `terraform plan/apply`.

## Região

- `us-east-1`

## Resultado

Foi identificada apenas a infraestrutura default do Lab:

- VPC default: `vpc-033e0adea829b5c00`
- CIDR: `172.31.0.0/16`
- estado: `available`
- 6 subnets default, uma por AZ;
- subnets com `MapPublicIpOnLaunch=True`;
- Internet Gateway default anexado;
- nenhum NAT Gateway;
- nenhum Elastic IP;
- apenas Security Group default.

## Interpretação

O ambiente está limpo para criação controlada da infraestrutura da Fase 3.

A VPC default existe, mas a estratégia Terraform da Fase 3 continua sendo criar infraestrutura própria e rastreada por Terraform.

## O que NÃO foi executado

Não foi executado:

- `terraform plan`;
- `terraform apply`;
- `terraform destroy`;
- `kubectl apply`;
- `helm install`;
- `helm upgrade`;
- criação de recurso AWS.

## Status

Inventário read-only concluído.
