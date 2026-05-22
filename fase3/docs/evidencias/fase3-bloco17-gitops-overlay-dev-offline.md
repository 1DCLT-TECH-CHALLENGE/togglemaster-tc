# Fase 3 - BLOCO 17 - GitOps overlay dev offline

Data: 2026-05-22

## Objetivo

Criar o overlay `dev` do GitOps/Kubernetes da Fase 3, ainda sem conexão com AWS e sem cluster Kubernetes real.

## Arquivos criados

- `gitops/overlays/dev/kustomization.yaml`

## Decisões

O overlay `dev` usa:

- `resources: ../../base`;
- label `environment: dev`;
- sem `nameSuffix`, mantendo nomes de Services estáveis;
- replicas explícitas para os cinco microsserviços.

## Validação anterior

O render local do Kustomize base foi executado com sucesso usando:

- `kubectl kustomize fase3/gitops/base`

O resultado renderizou:

- Namespace;
- ConfigMap;
- Services;
- Deployments.

## Restrições respeitadas

Não foi executado:

- `kubectl apply`;
- conexão com cluster;
- conexão com AWS;
- `terraform plan`;
- `terraform apply`;
- criação de recurso AWS.

## Status

Overlay `dev` criado, corrigido e validado por render local do Kustomize.

## Correção pós-criação

Após validação do render, foi removido `nameSuffix: -dev`.

Motivo:

- o sufixo alterava os nomes dos Services para `*-dev`;
- o ConfigMap base ainda apontava para `auth-service`, `flag-service` e `targeting-service`;
- isso poderia quebrar service discovery interno.

Decisão:

- manter os nomes dos Services estáveis;
- usar label `environment: dev`;
- usar replicas explícitas no overlay;
- deixar namespace/renomeação para decisão futura, se necessário.
