# Índice Final do GitHub - ToggleMaster TC

Este índice orienta a revisão do repositório após a entrega da Fase 4.

## Visão geral

- README raiz: visão geral do projeto, fases, bootstraps e estado pós-entrega.
- bootstraps/README.md: descrição dos bootstraps oficiais.
- _shared/docs/operacional/guia-reproducibilidade-fases.md: comandos por fase.
- fase4/docs/fase4-matriz-requisitos.md: matriz de aderência da Fase 4.
- fase4/docs/evidencias/: evidências técnicas da Fase 4.
- fase4/docs/adr/: decisões arquiteturais da Fase 4.
- fase4/gitops/: manifests GitOps da observabilidade.
- fase3/terraform/: infraestrutura cloud via Terraform.
- fase3/gitops/: manifests GitOps da aplicação ToggleMaster.

## Bootstraps

- 00_prepare_vm.sh: prepara VM Ubuntu.
- 01_bootstrap_fase1.sh: sobe e valida Fase 1 local.
- 02_bootstrap_fase2.sh: reconstrói e valida Fase 2 local.
- 03_bootstrap_fase3.sh: cria Fase 3 cloud via Terraform/IaC.
- 04_bootstrap_fase4.sh: aplica Fase 4 sobre a Fase 3.
- 05_validate_repo_final.sh: valida repositório.
- 06_destroy_aws_resources.sh: destroy controlado da AWS.

## Fase 4 - principais evidências

- fase4-bloco30-prometheus-grafana-argocd.md
- fase4-bloco31-grafana-access.md
- fase4-bloco32-grafana-dashboard-customizado.md
- fase4-bloco33-12-promtail-logs-loki.md
- fase4-bloco34-otel-collector.md
- fase4-bloco35-9b-trafego-newrelic-apm.md
- fase4-bloco37-1-alerta-prometheus-firing.md
- fase4-bloco38-3-chatops-discord.md
- fase4-bloco39-1-self-healing.md
- fase4-fechamento-final-pos-entrega.md

## Estado pós-entrega

A entrega da Fase 4 foi concluída com relatório e vídeo. Após a confirmação da entrega, a infraestrutura AWS Academy foi destruída por Terraform para evitar consumo do laboratório.

## Segurança

Não versionar secrets reais, tokens, tfstate, tfplan, vídeos ou artefatos gerados localmente.
