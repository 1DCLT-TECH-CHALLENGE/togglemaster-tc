# Fase 4 - BLOCO 35.6 - Push ECR e rollout GitOps das imagens OTEL

Data: Sat May 23 06:24:49 PM -03 2026

## Objetivo
Publicar as imagens instrumentadas no ECR, atualizar GitOps e validar rollout no EKS.

## Tag publicada
otel-b4f0b5c

## Repositórios usados
```text
evaluation-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
flag-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
targeting-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
```

## Manifests atualizados
```text
fase3/gitops/base/evaluation-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:otel-b4f0b5c
fase3/gitops/base/flag-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:otel-b4f0b5c
fase3/gitops/base/targeting-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c
```

## Validação Kustomize
```text
285:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:otel-b4f0b5c
340:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:otel-b4f0b5c
395:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c
```
