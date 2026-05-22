# Fase 3 - BLOCO 14 - Módulo Secrets offline

Data: 2026-05-22

## Objetivo

Criar e conectar o módulo Terraform de AWS Secrets Manager da Fase 3, ainda sem conexão com AWS.

## Decisão de segurança

O módulo cria apenas metadados de secrets.

Ele não cria `aws_secretsmanager_secret_version`.

Isso evita versionar ou gravar no Terraform state valores reais como:

- senhas;
- tokens;
- API keys;
- connection strings;
- credenciais temporárias.

## Secrets modelados

- `auth-service-config`
- `flag-service-config`
- `targeting-service-config`
- `evaluation-service-config`
- `analytics-service-config`

## Relação com RDS

O módulo RDS usa `manage_master_user_password = true`, portanto os secrets de senha master do RDS serão gerenciados pelo próprio RDS.

Os secrets deste módulo são para metadados/configuração futura de runtime das aplicações.

## Ponto de atenção AWS Academy

Antes de `terraform plan/apply`, validar se a `LabRole` permite criar secrets no AWS Secrets Manager.

Se o AWS Academy não permitir, será necessário usar fallback seguro documentado, sem versionar segredo.

## Restrições respeitadas

Não foi executado:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- login no AWS Academy.

## Status

Módulo Secrets criado e conectado ao ambiente `dev` para validação local posterior.
