# Fase 3 - BLOCO 05 - Módulo security offline

Data: 2026-05-22

## Objetivo

Criar o módulo Terraform de Security Groups da Fase 3, ainda sem conexão com AWS.

## Recursos modelados

- Security Group para Load Balancer público;
- Security Group adicional para EKS control plane;
- Security Group para EKS nodes;
- Security Group para RDS PostgreSQL;
- Security Group para ElastiCache Redis.

## Regras modeladas

- HTTP/HTTPS público para Load Balancer;
- tráfego NodePort a partir do SG do ALB para nodes;
- comunicação interna entre nodes;
- tráfego PostgreSQL apenas a partir dos nodes EKS;
- tráfego Redis apenas a partir dos nodes EKS.

## Restrições respeitadas

Não foi executado:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- login no AWS Academy.

## Arquivos criados

- `terraform/modules/security/variables.tf`
- `terraform/modules/security/main.tf`
- `terraform/modules/security/outputs.tf`

## Status

Módulo security criado para conexão ao ambiente `dev` no próximo bloco.
