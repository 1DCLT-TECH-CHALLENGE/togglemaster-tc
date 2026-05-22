# Fase 3 - BLOCO 01 - Fundação offline

Data: 2026-05-22

## Objetivo

Criar a fundação local da Fase 3 sem conexão com AWS.

## Escopo deste bloco

Este bloco prepara apenas estrutura, documentação e guardrails.

Não executa:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- criação de recurso AWS;
- login no AWS Academy.

## Premissas

- O ambiente cloud real será o AWS Academy Lab.
- A única role permitida para EKS e Node Groups será a `LabRole`.
- Nenhuma credencial AWS deve ser versionada.
- Nenhum state Terraform real deve ser versionado.
- A Fase 2 local permanece como baseline funcional validado.
- A Fase 3 substituirá a infraestrutura local/simulada por recursos AWS reais via Terraform/IaC.

## Estrutura criada

- `fase3/terraform/environments/dev`
- `fase3/terraform/modules/networking`
- `fase3/terraform/modules/security`
- `fase3/terraform/modules/eks`
- `fase3/terraform/modules/ecr`
- `fase3/terraform/modules/rds`
- `fase3/terraform/modules/elasticache`
- `fase3/terraform/modules/sqs`
- `fase3/terraform/modules/dynamodb`
- `fase3/terraform/modules/secrets`
- `fase3/terraform/modules/argocd`
- `fase3/gitops`
- `fase3/kubernetes`
- `fase3/.github/workflows`
- `fase3/docs/adr`
- `fase3/docs/evidencias`

## Status

Fundação offline da Fase 3 criada.
