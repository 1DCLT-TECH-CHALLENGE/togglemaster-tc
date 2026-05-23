# Fase 3 - AWS Academy - BLOCO AWS-14 - Inventário pré-deploy

Data: 2026-05-22

## Objetivo

Registrar o inventário pré-deploy da infraestrutura AWS/Kubernetes antes de iniciar build/push das imagens e deploy dos microsserviços.

## Git

O repositório estava limpo e sincronizado com origin/main.

Último commit observado:

- a16655e docs: record aws academy lab resume validation

## Kubernetes

Cluster validado com 2 nodes Ready:

- ip-10-10-39-217.ec2.internal
- ip-10-10-56-35.ec2.internal

Namespaces existentes:

- default
- kube-node-lease
- kube-public
- kube-system

Pods kube-system em Running:

- aws-node
- kube-proxy
- coredns

## ECR

Repositórios ECR existentes:

- togglemaster-dev/auth-service
- togglemaster-dev/flag-service
- togglemaster-dev/targeting-service
- togglemaster-dev/evaluation-service
- togglemaster-dev/analytics-service

Contagem de imagens no momento do inventário:

- auth-service: 0
- flag-service: 0
- targeting-service: 0
- evaluation-service: 0
- analytics-service: 0

## RDS

Endpoints RDS disponíveis:

- auth
- flags
- targeting

## Redis

Endpoint Redis disponível:

- togglemaster-dev-redis.hmdfss.ng.0001.use1.cache.amazonaws.com

## SQS

Fila SQS disponível:

- togglemaster-dev-togglemaster-events

## DynamoDB

Tabela DynamoDB disponível:

- togglemaster-dev-ToggleMasterAnalytics

## Interpretação

A infraestrutura cloud da Fase 3 está pronta para a próxima etapa.

Ainda não existem imagens Docker publicadas no ECR, portanto o próximo bloco deve tratar build, tag e push das imagens dos cinco microsserviços.

## Status

BLOCO AWS-14 concluído com sucesso.
