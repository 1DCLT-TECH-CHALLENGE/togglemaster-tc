# Fase 3 - BLOCO 16 - GitOps base offline

Data: 2026-05-22

## Objetivo

Criar a base GitOps/Kubernetes da Fase 3, ainda sem conexão com AWS e sem cluster Kubernetes real.

## Arquivos criados

- `gitops/base/namespace.yaml`
- `gitops/base/configmap.yaml`
- `gitops/base/auth-service.yaml`
- `gitops/base/flag-service.yaml`
- `gitops/base/targeting-service.yaml`
- `gitops/base/evaluation-service.yaml`
- `gitops/base/analytics-service.yaml`
- `gitops/base/kustomization.yaml`

## Decisões

Os manifests usam imagens placeholder `REPLACE_WITH_ECR_*`.

Essas imagens serão substituídas posteriormente por URLs reais de ECR após a etapa AWS Academy/Terraform/ECR.

Nenhum Secret real foi criado.

Nenhuma senha, token, API key ou connection string real foi versionada.

## Restrições respeitadas

Não foi executado:

- `kubectl apply`;
- conexão com cluster;
- conexão com AWS;
- `terraform plan`;
- `terraform apply`;
- criação de recurso AWS.

## Status

Base GitOps criada para validação local posterior.
