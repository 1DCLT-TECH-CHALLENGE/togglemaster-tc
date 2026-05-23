# Fase 3 - AWS Academy - BLOCO AWS-13 - Retomada do Lab validada

Data: 2026-05-22

## Objetivo

Registrar a retomada do AWS Academy Lab após pausa/expiração da sessão anterior.

## Credenciais

As credenciais temporárias da nova sessão foram carregadas na VM sem versionamento.

Validação executada:

- AWS_ACCESS_KEY_ID presente
- AWS_SECRET_ACCESS_KEY presente
- AWS_SESSION_TOKEN presente
- aws sts get-caller-identity OK

Conta validada:

- 590183666984

Role/sessão validada:

- assumed-role/voclabs

## Sanity check de retomada

O sanity check confirmou:

- Git limpo
- HEAD sincronizado com origin/main no commit ec9ecd7
- EKS cluster togglemaster-dev-eks ACTIVE
- EKS node group togglemaster-dev-default-ng ACTIVE
- 2 nodes Kubernetes Ready
- pods kube-system Running

Observação:

Os nomes e IPs dos nodes mudaram em relação ao checkpoint anterior, mas o node group permaneceu funcional e saudável.

## Drift check Terraform

Foi executado:

terraform plan -no-color -detailed-exitcode

Resultado:

- PLAN_RC=0
- No changes. Your infrastructure matches the configuration.

## Interpretação

A infraestrutura AWS criada na Fase 3 foi preservada entre sessões do AWS Academy Lab.

O Terraform local continua idempotente e alinhado com a infraestrutura real.

## Status

BLOCO AWS-13 concluído com sucesso.
