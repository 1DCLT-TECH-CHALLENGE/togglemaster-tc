# Fase 3 - BLOCO 07 - Módulo ECR offline

Data: 2026-05-22

## Objetivo

Criar e conectar o módulo Terraform de ECR para os microsserviços da Fase 3, ainda sem conexão com AWS.

## Serviços contemplados

A lista de serviços vem da variável `service_names` do ambiente `dev`:

- `auth-service`
- `flag-service`
- `targeting-service`
- `evaluation-service`
- `analytics-service`

## Recursos modelados

- `aws_ecr_repository` para cada serviço;
- `aws_ecr_lifecycle_policy` para manter apenas as últimas 10 imagens;
- scan de imagem no push habilitado por padrão;
- criptografia AES256 padrão;
- outputs de nomes, URLs e ARNs dos repositórios.

## Ambiente dev

O módulo `ecr` foi conectado em:

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
- login no AWS Academy;
- push de imagens para ECR real.

## Status

Módulo ECR criado e conectado ao ambiente `dev` para validação local posterior.
