# ADR-003 - Correção de Capacidade para Observabilidade da Fase 4

## Status

Proposta aprovada para próximo bloco de alteração IaC, ainda sem apply nesta etapa.

## Contexto

O BLOCO 24 confirmou que o cluster atual não possui folga de pods para instalar a stack de observabilidade da Fase 4.

Estado observado:

- 2 nodes `t3.small`;
- 22 pods usados de 22 possíveis;
- 0 pods livres;
- necessidade estimada mínima: 14 pods livres para stack base e margem operacional.

A Fase 4 exige Prometheus, Grafana, Loki, OpenTelemetry Collector, APM, alertas, incidentes, ChatOps e self-healing operando na prática. Portanto, instalar a stack sem corrigir capacidade seria inseguro.

## Opções consideradas

### Opção A - Apenas subir para 3 nodes t3.small

Menor alteração possível, porém insuficiente conforme cálculo do BLOCO 25.

### Opção B - Subir para 4 nodes t3.small

Mantém o instance type atual e amplia a quantidade de nodes via IaC. É a menor alteração com capacidade calculada como viável no planejamento.

### Opção C - Trocar instance type

Pode resolver memória e pods com menos nodes, porém envolve maior impacto operacional no node group e maior risco no AWS Academy.

## Decisão

A decisão proposta é iniciar pela Opção B:

- manter `t3.small`;
- ajustar node group via Terraform para:
  - `node_min_size = 2`;
  - `node_desired_size = 5`;
  - `node_max_size = 5`.

## Consequências

- O próximo bloco deve alterar somente o código Terraform/IaC.
- Depois disso deve ser executado `terraform plan`.
- O `terraform apply` deve ocorrer em bloco separado, somente após revisão do plano.
- Após o apply, deve ser executado novo capacity gate.
- Só depois disso será permitido instalar a stack de observabilidade.

## Segurança

- Nenhuma credencial será versionada.
- Nenhum `tfstate`, `terraform.tfvars` real ou `*.auto.tfvars` será versionado.
- A execução seguirá AWS Academy com LabRole.
