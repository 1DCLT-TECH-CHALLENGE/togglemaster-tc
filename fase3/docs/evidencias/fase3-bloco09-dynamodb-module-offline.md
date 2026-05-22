# Fase 3 - BLOCO 09 - Módulo DynamoDB offline

Data: 2026-05-22

## Objetivo

Criar e conectar o módulo Terraform de DynamoDB da Fase 3, ainda sem conexão com AWS.

## Contexto

Na Fase 2 local, o `analytics-service` grava eventos de avaliação em uma tabela DynamoDB simulada no LocalStack.

Na Fase 3, essa tabela será modelada em AWS real via Terraform.

## Recursos modelados

- `aws_dynamodb_table` para eventos de analytics;
- chave primária `event_id`;
- billing mode `PAY_PER_REQUEST`;
- Point-in-Time Recovery configurável;
- TTL configurável;
- outputs de nome, ARN e ID da tabela.

## Ambiente dev

O módulo `dynamodb` foi conectado em:

- `terraform/environments/dev/main.tf`

Outputs adicionados em:

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

Módulo DynamoDB criado e conectado ao ambiente `dev` para validação local posterior.
