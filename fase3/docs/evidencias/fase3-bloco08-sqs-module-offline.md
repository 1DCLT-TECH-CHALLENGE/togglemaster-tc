# Fase 3 - BLOCO 08 - Módulo SQS offline

Data: 2026-05-22

## Objetivo

Criar e conectar o módulo Terraform de SQS da Fase 3, ainda sem conexão com AWS.

## Contexto

Na Fase 2 local, o `evaluation-service` envia eventos de avaliação para uma fila SQS simulada no LocalStack.

Na Fase 3, essa fila será modelada em AWS real via Terraform.

## Recursos modelados

- `aws_sqs_queue` para eventos de avaliação;
- criptografia gerenciada pelo SQS habilitada;
- retenção padrão de mensagens;
- visibility timeout configurável;
- outputs de nome, URL e ARN.

## Ambiente dev

O módulo `sqs` foi conectado em:

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

Módulo SQS criado e conectado ao ambiente `dev` para validação local posterior.
