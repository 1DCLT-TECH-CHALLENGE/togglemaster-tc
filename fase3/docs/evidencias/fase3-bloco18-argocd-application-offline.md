# Fase 3 - BLOCO 18 - ArgoCD Application offline

Data: 2026-05-22

## Objetivo

Criar o manifesto base de ArgoCD Application para a Fase 3, ainda sem conexão com AWS e sem cluster Kubernetes real.

## Arquivos criados

- `gitops/apps/togglemaster-dev-application.yaml`
- `gitops/apps/kustomization.yaml`

## Decisão

O ArgoCD Application aponta para:

- repositório: `git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git`
- branch: `main`
- path: `fase3/gitops/overlays/dev`

## Política de sync

A política definida no manifesto inclui:

- `prune: true`
- `selfHeal: true`
- `CreateNamespace=true`

## Observações

Este manifesto pressupõe que o ArgoCD já esteja instalado no cluster e que tenha acesso ao repositório GitHub.

A instalação/configuração real do ArgoCD será tratada em etapa própria, respeitando AWS Academy, EKS e permissões disponíveis.

## Restrições respeitadas

Não foi executado:

- `kubectl apply`;
- conexão com cluster;
- conexão com AWS;
- `terraform plan`;
- `terraform apply`;
- criação de recurso AWS.

## Status

Manifesto ArgoCD Application criado para validação local posterior.
