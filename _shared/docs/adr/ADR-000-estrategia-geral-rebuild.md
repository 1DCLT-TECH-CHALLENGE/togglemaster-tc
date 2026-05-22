# ADR-000 - Estratégia geral do rebuild ToggleMaster TC

Data: 2026-05-22

## Status

Aceita.

## Contexto

O projeto ToggleMaster TC está sendo reconstruído em uma nova VM, após os recursos anteriores do AWS Academy terem sido removidos.

As Fases 1, 2 e 3 já existiram anteriormente como entregas acadêmicas. A Fase 4 ainda será implementada.

O objetivo atual é reconstruir a base das Fases 1 a 3 de forma controlada, versionada e reprodutível, para então implementar e subir a Fase 4.

## Decisão

O rebuild será organizado por fases, com bootstraps separados e isolados.

Cada fase deve ter seu próprio bootstrap, sua própria estrutura, sua própria documentação, suas próprias evidências e seus próprios scripts.

Estrutura raiz esperada:

    ~/togglemaster-tc/
      bootstraps/
      _shared/
      fase1/
      fase2/
      fase3/
      fase4/

## Responsabilidade dos bootstraps

### Bootstrap de VM / fundação

Responsável por preparar a VM do zero com ferramentas base.

Inclui:

- pacotes do sistema;
- Docker;
- Docker Compose;
- Git;
- Terraform;
- kubectl;
- Helm;
- AWS CLI;
- Go;
- pyenv;
- Python compatível;
- estrutura raiz mínima;
- helpers compartilhados.

Não deve subir aplicações de fase.

### Bootstrap da Fase 1

Responsável pela reconstrução da Fase 1.

Deve:

- criar a estrutura da Fase 1;
- preparar o monólito local;
- criar scripts operacionais;
- subir a aplicação local;
- testar health/CRUD;
- gerar evidências.

Não depende de AWS.

### Bootstrap da Fase 2

Responsável pela reconstrução completa da Fase 2 local.

Deve:

- criar estrutura de diretórios;
- criar documentos;
- criar scripts;
- aplicar correções de runtime;
- preparar Dockerfiles;
- preparar Docker Compose;
- subir PostgreSQL, Redis e LocalStack;
- criar SQS e DynamoDB locais;
- subir os cinco microsserviços;
- validar o fluxo E2E;
- gerar evidências.

A cadeia validada da Fase 2 é:

    12_apply_runtime_patches.sh
    15_fix_phase2_compose_runtime.sh
    16_stabilize_phase2_runtime.sh
    17_validate_phase2_e2e_flow.sh

### Bootstrap da Fase 3

Responsável por IaC, cloud, GitOps e DevSecOps.

Não deve recriar responsabilidades da Fase 2.

Deve:

- criar estrutura Terraform;
- criar módulos Terraform;
- preparar ambiente dev;
- criar GitOps/Kubernetes manifests;
- criar workflows;
- validar offline;
- preparar uso do AWS Academy;
- respeitar LabRole;
- não criar IAM Roles/Policies arbitrárias;
- não executar terraform plan/apply sem AWS Academy Lab aberto.

### Bootstrap da Fase 4

Responsável pela camada de observabilidade, APM, alertas, incidentes e self-healing.

Não deve subir novamente Fase 2 nem Fase 3.

Deve assumir que:

- Fase 2 já está funcional;
- Fase 3 já provisionou a base cloud;
- aplicações já estão implantáveis;
- cluster e workloads existem.

A Fase 4 deve cuidar de:

- observabilidade;
- métricas;
- logs;
- traces;
- dashboards;
- alertas;
- ChatOps;
- resposta a incidentes;
- self-healing quando aplicável.

## Regras operacionais

O rebuild deve seguir as seguintes regras:

- sem workarounds ou gambiarras;
- sem ignorar problemas quando é possível resolver;
- optar pela solução definitiva;
- manter idempotência;
- registrar evidências;
- versionar tudo que for necessário;
- não versionar credenciais;
- não versionar logs, tmp, states, tfvars reais ou chaves runtime;
- separar claramente responsabilidades entre fases.

## GitHub

Todo o projeto deve estar versionado em:

    1DCLT-TECH-CHALLENGE/togglemaster-tc

O repositório deve permitir:

- revisão de histórico;
- auditoria;
- reconstrução;
- alteração;
- validação;
- evolução incremental;
- documentação das decisões.
