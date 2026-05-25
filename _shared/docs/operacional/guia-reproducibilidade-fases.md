# Guia de Reprodutibilidade por Fase

Este documento consolida a forma esperada de reconstruir o projeto ToggleMaster TC por fase.

## Fase 1

Escopo: aplicação monolítica/MVP local, sem AWS.

Comando principal:

./bootstraps/01_bootstrap_fase1.sh

## Fase 2

Escopo: cinco microsserviços locais, PostgreSQL, Redis, LocalStack, SQS local, DynamoDB local e analytics.

Comando principal:

./bootstraps/02_bootstrap_fase2.sh

Para resetar volumes e containers locais antes da execução:

BOOTSTRAP_RESET_LOCAL=true ./bootstraps/02_bootstrap_fase2.sh

## Fase 3

Escopo: infraestrutura cloud via Terraform/IaC, usando a base dos microsserviços da Fase 2.

Gerar plano sem aplicar recursos:

./bootstraps/03_bootstrap_fase3.sh

Aplicar recursos AWS de forma controlada:

CONFIRM_AWS_COSTS=SIM ./bootstraps/03_bootstrap_fase3.sh

## Fase 4

Escopo: observabilidade, logs, APM, alertas, incidentes, ChatOps e self-healing sobre a Fase 3.

Comando principal:

NEW_RELIC_LICENSE_KEY="..." PAGERDUTY_ROUTING_KEY="..." DISCORD_WEBHOOK_URL="..." ./bootstraps/04_bootstrap_fase4.sh

## Validação final

./bootstraps/05_validate_repo_final.sh

## Destroy AWS

Gerar plano de destroy:

./bootstraps/06_destroy_aws_resources.sh

Aplicar destroy confirmado:

CONFIRM_DESTROY=SIM ./bootstraps/06_destroy_aws_resources.sh

## Segurança

Secrets reais nunca devem ser versionados no GitHub. Integrações externas devem usar variáveis de ambiente, secrets do Kubernetes ou mecanismo seguro equivalente.
