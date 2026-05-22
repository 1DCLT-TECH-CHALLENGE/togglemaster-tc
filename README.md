# ToggleMaster TC - FIAP Tech Challenge

Repositório de reconstrução local e evolução do projeto ToggleMaster para o FIAP Tech Challenge.

Organization GitHub:

- `1DCLT-TECH-CHALLENGE`

Repositório:

- `togglemaster-tc`

## Status geral

| Fase | Status | Observação |
|---|---|---|
| Fase 1 | Estrutura e validação local registradas | Monólito local usado como baseline inicial |
| Fase 2 | Fechada, validada, consolidada e versionada | Microsserviços locais com Docker Compose, PostgreSQL, Redis, LocalStack, SQS e DynamoDB |
| Fase 3 | Estrutura inicial criada | Próxima fase: IaC/Terraform/GitOps/AWS Academy |
| Fase 4 | Estrutura inicial criada | Próxima etapa após consolidação da Fase 3 |

## Fase 2 - Estado validado

A Fase 2 local foi validada end-to-end e consolidada nos scripts operacionais.

Cadeia principal validada:

    ./fase2/local/scripts/12_apply_runtime_patches.sh
    ./fase2/local/scripts/15_fix_phase2_compose_runtime.sh
    ./fase2/local/scripts/16_stabilize_phase2_runtime.sh
    ./fase2/local/scripts/17_validate_phase2_e2e_flow.sh

Fluxo validado:

1. Build e subida dos 5 microsserviços.
2. Health check de `auth-service`, `flag-service`, `targeting-service`, `evaluation-service` e `analytics-service`.
3. Criação dinâmica de API key no `auth-service`.
4. Criação/listagem da flag `enable-new-dashboard`.
5. Criação/consulta da regra de targeting `PERCENTAGE` 50.
6. Avaliação da flag no `evaluation-service`.
7. Envio de eventos para SQS no LocalStack.
8. Consumo pelo `analytics-service`.
9. Gravação no DynamoDB LocalStack.

## Evidências principais da Fase 2

- `fase2/docs/evidencias/fase2-fechamento-local.md`
- `fase2/docs/evidencias/fase2-bloco17-validacao-e2e.md`
- `fase2/docs/evidencias/fase2-bloco18-consolidacao-pos-e2e.md`

## Docker Compose principal da Fase 2

Arquivo principal:

    fase2/docker/docker-compose.phase2-exec.yaml

Arquivo de exemplo de ambiente:

    fase2/docker/.env.example

O arquivo local real `.env.phase2.local` não é versionado.

## Segurança e versionamento

Este repositório ignora:

- arquivos `.env` locais;
- logs;
- diretórios `tmp`;
- backups `.bak` e `.bkp`;
- repositórios upstream clonados localmente;
- binários gerados;
- estados Terraform e tfvars reais.

Antes do primeiro commit foi executada auditoria para evitar versionamento de credenciais, logs, backups, binários e chaves runtime.

## Próximo objetivo

Próxima etapa planejada:

- iniciar/consolidar a Fase 3 com IaC, Terraform, GitOps e AWS Academy/LabRole;
- manter Fase 2 como baseline local funcional;
- não criar recursos AWS manualmente fora da automação/IaC da Fase 3.
