# Fase 3 - AWS Academy - BLOCO AWS-15C - Build e push das imagens para ECR

Data: 2026-05-22

## Objetivo

Registrar o build e push das imagens Docker dos cinco microsserviços para o Amazon ECR.

## Contexto

O inventário pré-deploy confirmou que os cinco repositórios ECR existiam, mas ainda estavam sem imagens.

Foi realizado login Docker no ECR e em seguida build/push das imagens a partir dos serviços consolidados da Fase 2.

## Registry ECR

Registry utilizado:

- 590183666984.dkr.ecr.us-east-1.amazonaws.com

## Tag utilizada

Tag baseada no commit Git atual:

- c0f03bb

## Contextos de build

Foram usados os seguintes diretórios:

- fase2/src/services/auth-service
- fase2/src/services/flag-service
- fase2/src/services/targeting-service
- fase2/src/services/evaluation-service
- fase2/src/services/analytics-service

## Imagens publicadas

Foram publicadas as seguintes imagens:

- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
- 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb

## Resultado

O build e push foram concluídos com sucesso para os cinco microsserviços.

O ECR confirmou a presença da tag c0f03bb em todos os repositórios.

## Observação

O comando describe-images também exibiu imagens sem tag. Essas entradas são artefatos/attestations gerados pelo processo de build/push, mas a tag c0f03bb foi confirmada nas cinco imagens principais.

## Git

O repositório permaneceu limpo após o build/push.

## Status

BLOCO AWS-15C concluído com sucesso.
