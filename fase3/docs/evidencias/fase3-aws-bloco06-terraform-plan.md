# Fase 3 - AWS Academy - BLOCO AWS-06 - Terraform plan controlado

Data: 2026-05-22

## Objetivo

Executar o primeiro `terraform plan` real contra o AWS Academy Lab, ainda sem aplicar mudanças.

## Região

- `us-east-1`

## Arquivos locais gerados

Os arquivos foram gerados em `fase3/logs/`, diretório não versionado:

- plan binário: `fase3/logs/fase3-dev-20260522-195407.tfplan`
- log do plan: `fase3/logs/fase3-dev-20260522-195407-plan.log`
- plan em texto: `fase3/logs/fase3-dev-20260522-195407-plan.txt`

## Resultado

O `terraform plan` foi executado com sucesso.

Resultado:

- `PLAN_RC=0`
- `Plan: 49 to add, 0 to change, 0 to destroy.`

## Principais recursos planejados

O plano prevê criação de:

- VPC própria `10.10.0.0/16`;
- subnets públicas;
- subnets privadas;
- Internet Gateway;
- NAT Gateway;
- Elastic IP para NAT;
- route tables e rotas;
- Security Groups;
- ECR repositories;
- SQS queue;
- DynamoDB table;
- RDS PostgreSQL;
- ElastiCache Redis;
- Secrets Manager metadata;
- EKS cluster;
- EKS managed node group.

## Pontos de atenção

O plan valida sintaxe, dependências Terraform e leitura básica da AWS, mas não garante que todas as permissões de criação serão aceitas no `apply`.

Como o conteúdo das `VocLabPolicy*` não pode ser inspecionado por limitação do AWS Academy, possíveis falhas de permissão só serão confirmadas durante o `terraform apply`.

## O que NÃO foi executado

Não foi executado:

- `terraform apply`;
- `terraform destroy`;
- `kubectl apply`;
- `helm install`;
- `helm upgrade`;
- push de imagem para ECR;
- deploy em EKS.

## Status

Terraform plan controlado concluído com sucesso.

Próximo passo: revisão final antes do primeiro `terraform apply`.
