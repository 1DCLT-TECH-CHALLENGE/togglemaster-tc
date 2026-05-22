# Fase 3 - AWS Academy - BLOCO AWS-07 - Timeout no Terraform apply do EKS

Data: 2026-05-22

## Objetivo

Registrar o primeiro `terraform apply` real da Fase 3 no AWS Academy e o timeout ocorrido durante a criação do EKS.

## Resultado do apply

O `terraform apply` foi iniciado a partir do plano salvo previamente.

O apply criou com sucesso diversos recursos da infraestrutura, incluindo:

- VPC;
- subnets;
- route tables;
- Internet Gateway;
- NAT Gateway;
- EIP;
- Security Groups;
- ECR repositories;
- Secrets Manager metadata;
- SQS;
- DynamoDB;
- RDS PostgreSQL;
- ElastiCache Redis;
- Launch Template dos nodes.

## Falha observada

O apply falhou por timeout aguardando o cluster EKS ficar `ACTIVE`.

Erro observado:

`timeout while waiting for state to become 'ACTIVE' (last state: 'CREATING', timeout: 30m0s)`

## Diagnóstico posterior

Após o timeout:

- o cluster `togglemaster-dev-eks` ainda existia na AWS;
- o status do cluster era `CREATING`;
- não havia node groups criados;
- o Terraform state já continha `module.eks.aws_eks_cluster.this`;
- o Terraform state já continha `module.eks.aws_launch_template.nodes`.

## Interpretação

A AWS aceitou a criação do cluster EKS, mas o tempo padrão de espera do provider Terraform foi insuficiente para o ambiente AWS Academy.

Não foi executado `destroy`.

Não foi feita alteração manual no console.

## Correção aplicada

Foram adicionados timeouts explícitos no módulo `eks`:

- `aws_eks_cluster.this`:
  - `create = "75m"`
  - `update = "75m"`
  - `delete = "60m"`

- `aws_eks_node_group.default`:
  - `create = "75m"`
  - `update = "75m"`
  - `delete = "60m"`

## Próximo passo

Aguardar o cluster sair de `CREATING`.

Se o cluster ficar `ACTIVE`, executar novo `terraform plan` e depois `terraform apply` controlado para continuar a criação do node group e finalizar a Fase 3.
