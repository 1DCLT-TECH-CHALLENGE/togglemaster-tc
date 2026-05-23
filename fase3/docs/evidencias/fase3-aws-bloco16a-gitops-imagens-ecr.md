# Fase 3 - AWS Academy - BLOCO AWS-16A - GitOps atualizado com imagens ECR

Data: 2026-05-22

## Objetivo

Registrar a atualização dos manifests GitOps para apontar para as imagens reais publicadas no Amazon ECR.

## Contexto

Após o BLOCO AWS-15C, as cinco imagens Docker dos microsserviços foram publicadas no ECR com a tag c0f03bb.

Antes deste bloco, os manifests GitOps ainda usavam placeholders:

- REPLACE_WITH_ECR_AUTH_SERVICE_IMAGE
- REPLACE_WITH_ECR_FLAG_SERVICE_IMAGE
- REPLACE_WITH_ECR_TARGETING_SERVICE_IMAGE
- REPLACE_WITH_ECR_EVALUATION_SERVICE_IMAGE
- REPLACE_WITH_ECR_ANALYTICS_SERVICE_IMAGE

## Imagens configuradas

Os manifests foram atualizados para usar:

- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb

## Arquivos alterados

- fase3/gitops/base/auth-service.yaml
- fase3/gitops/base/flag-service.yaml
- fase3/gitops/base/targeting-service.yaml
- fase3/gitops/base/evaluation-service.yaml
- fase3/gitops/base/analytics-service.yaml

## Validações executadas

Foi validado que:

- não restaram placeholders REPLACE_WITH_ECR;
- não restaram imagens malformadas com registry vazio;
- o render do Kustomize overlay dev foi executado com sucesso;
- os cinco Deployments renderizados apontam para as imagens ECR corretas.

## O que NÃO foi executado

Não foi executado:

- kubectl apply;
- instalação do ArgoCD;
- sync de aplicação no cluster;
- alteração manual no console AWS.

## Status

BLOCO AWS-16A concluído com sucesso.
