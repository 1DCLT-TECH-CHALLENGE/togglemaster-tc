# Bootstraps ToggleMaster TC

Este diretorio contem os bootstraps oficiais do rebuild do ToggleMaster para o Tech Challenge FIAP.

## Escopo por fase

- Fase 1: monolito/MVP local, sem AWS.
- Fase 2: cinco microsservicos locais, sem AWS real, usando Docker Compose, PostgreSQL, Redis, LocalStack, SQS local, DynamoDB local e analytics.
- Fase 3: infraestrutura cloud via Terraform/IaC usando a estrutura da Fase 2.
- Fase 4: observabilidade, logs, APM, alertas, incidentes, ChatOps e self-healing sobre a Fase 3.

## Scripts

- 00_prepare_vm.sh: prepara VM Ubuntu com Docker, Terraform, kubectl, Helm, AWS CLI, Go, Python e utilitarios.
- 01_bootstrap_fase1.sh: sobe e valida a Fase 1 local.
- 02_bootstrap_fase2.sh: reconstrói e valida a Fase 2 local com cinco microsservicos.
- 03_bootstrap_fase3.sh: executa Terraform/IaC da Fase 3, build/push de imagens e GitOps. Requer AWS Academy.
- 04_bootstrap_fase4.sh: aplica observabilidade/APM/incidentes/ChatOps/self-healing da Fase 4.
- 05_validate_repo_final.sh: valida repo, artefatos proibidos, shell scripts, Terraform e render GitOps.
- 06_destroy_aws_resources.sh: gera e aplica destroy seguro dos recursos AWS gerenciados por Terraform.

## Ordem recomendada

1. ./bootstraps/00_prepare_vm.sh
2. ./bootstraps/01_bootstrap_fase1.sh
3. ./bootstraps/02_bootstrap_fase2.sh
4. CONFIRM_AWS_COSTS=SIM ./bootstraps/03_bootstrap_fase3.sh
5. NEW_RELIC_LICENSE_KEY="..." PAGERDUTY_ROUTING_KEY="..." DISCORD_WEBHOOK_URL="..." ./bootstraps/04_bootstrap_fase4.sh
6. ./bootstraps/05_validate_repo_final.sh

## Destroy AWS

Plano:
./bootstraps/06_destroy_aws_resources.sh

Aplicacao confirmada:
CONFIRM_DESTROY=SIM ./bootstraps/06_destroy_aws_resources.sh

## Seguranca

- Secrets reais nunca devem ser versionados.
- New Relic, PagerDuty e Discord devem ser passados por variavel de ambiente ou mecanismo seguro local.
- Arquivos .tfstate, .tfplan, videos, builds locais e temporarios sao ignorados pelo .gitignore.
- O destroy exige confirmacao explicita por variavel de ambiente.
