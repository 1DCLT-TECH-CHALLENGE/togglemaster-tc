# fase2 — ToggleMaster TC

Diretório da fase2 no rebuild ToggleMaster TC.

## Status atual

Estrutura inicial criada. Implementação técnica será adicionada na etapa específica da fase.

## Organização

- insumos/
- repos/upstream/
- src/
- local/scripts/
- docker/
- docs/
- logs/
- tmp/

<!-- TOGGLEMASTER_FINAL_NAV_START -->
## Reprodutibilidade da Fase 2

Escopo: cinco microsserviços locais, sem AWS real, usando Docker Compose, PostgreSQL, Redis, LocalStack, SQS local, DynamoDB local e analytics.

Comando principal:

`./bootstraps/02_bootstrap_fase2.sh`

Para resetar volumes e containers locais antes da execução:

`BOOTSTRAP_RESET_LOCAL=true ./bootstraps/02_bootstrap_fase2.sh`
<!-- TOGGLEMASTER_FINAL_NAV_END -->
