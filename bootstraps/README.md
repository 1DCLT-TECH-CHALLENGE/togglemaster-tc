# Bootstraps — ToggleMaster TC

Este diretório concentra os scripts de bootstrap do rebuild ToggleMaster TC.

## Estratégia

- `00_prepare_vm.sh`: preparação da VM e ferramentas base.
- `01_bootstrap_fase1.sh`: automação local da Fase 1.
- `02_bootstrap_fase2.sh`: automação local da Fase 2.
- `03_bootstrap_fase3.sh`: automação IaC/cloud da Fase 3 via Terraform/AWS Academy.
- `04_bootstrap_fase4.sh`: automação futura da Fase 4/observabilidade.

## Regras

- Scripts devem ser idempotentes sempre que possível.
- Não armazenar credenciais.
- Não executar Terraform apply sem etapa explícita e controlada.
- Não usar AWS antes da Fase 3.
- Registrar logs e evidências em `_shared` e/ou no diretório da fase correspondente.
