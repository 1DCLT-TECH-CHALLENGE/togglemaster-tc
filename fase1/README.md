# Fase 1 — ToggleMaster TC

A Fase 1 representa a base local/monolítica do ToggleMaster TC.

## Contexto

Esta fase já foi entregue anteriormente. No rebuild atual, ela será reconstruída apenas como baseline técnica local para preservar histórico, validar ambiente e manter o projeto completo antes de avançar para Fase 4.

## Objetivo no rebuild atual

- reconstruir a estrutura local da Fase 1;
- criar scripts idempotentes para execução local;
- validar a aplicação localmente quando o código estiver disponível;
- registrar evidências;
- manter a fase documentada para versionamento futuro no GitHub.

## O que esta fase NÃO fará agora

- não usará AWS;
- não usará Terraform;
- não criará infraestrutura cloud;
- não será demonstrada novamente como entrega isolada;
- não será tratada como dependência funcional obrigatória da Fase 2.

## Organização

- `insumos/`: materiais de referência da fase;
- `repos/upstream/`: repositórios originais/clonados, se aplicável;
- `src/`: código consolidado da fase;
- `local/scripts/`: scripts locais de execução, teste, parada e reset;
- `docker/`: arquivos Docker/Compose da fase;
- `docs/evidencias/`: evidências de execução;
- `logs/`: logs locais da fase;
- `tmp/`: arquivos temporários não versionáveis.

<!-- TOGGLEMASTER_FINAL_NAV_START -->
## Reprodutibilidade da Fase 1

Escopo: aplicação monolítica/MVP local, sem AWS.

Comando principal:

`./bootstraps/01_bootstrap_fase1.sh`
<!-- TOGGLEMASTER_FINAL_NAV_END -->
