# Fase 3 - BLOCO 21 - GitHub Actions offline

Data: 2026-05-22

## Objetivo

Criar workflows de validação offline da Fase 3 no GitHub Actions.

## Arquivos criados

- `.github/workflows/phase3-terraform-validate.yml`
- `.github/workflows/phase3-gitops-validate.yml`
- `.github/workflows/phase3-security-scan.yml`

## Decisão

Os workflows ficam na raiz do repositório, em `.github/workflows/`, porque esse é o local reconhecido pelo GitHub Actions.

Os workflows validam arquivos da Fase 3, mas não executam AWS.

## Workflows

### Phase 3 - Terraform Validate

Executa:

- `terraform fmt -recursive -check`;
- `terraform init -backend=false`;
- `terraform validate`.

### Phase 3 - GitOps Validate

Executa render local com:

- `kubectl kustomize fase3/gitops/base`;
- `kubectl kustomize fase3/gitops/overlays/dev`;
- `kubectl kustomize fase3/gitops/apps`.

### Phase 3 - Repository Safety Scan

Executa:

- checagem de arquivos proibidos versionados;
- busca básica por padrões óbvios de segredo;
- allowlist apenas para falsos positivos documentais e `manage_master_user_password = true`.

## Restrições respeitadas

Os workflows não executam:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- `kubectl apply`;
- deploy em cluster real;
- criação de recurso AWS.

## Status

Workflows offline da Fase 3 criados para validação em GitHub Actions.
