# ADR-001 - Fase 3 com AWS Academy e LabRole

Data: 2026-05-22

## Status

Aceita.

## Contexto

A Fase 3 é a primeira etapa do rebuild em que a AWS real será utilizada.

O ambiente alvo será o AWS Academy Lab, não uma conta AWS pessoal.

O AWS Academy impõe restrições de IAM. Portanto, o projeto não deve assumir liberdade para criar IAM Roles e Policies arbitrárias via Terraform.

## Decisão

A Fase 3 será construída com Terraform/IaC, mas adaptada ao AWS Academy.

Regras obrigatórias:

- Não criar IAM Roles novas para EKS.
- Não criar IAM Policies novas arbitrárias.
- Usar a role existente `LabRole`.
- Associar a `LabRole` ao EKS Cluster.
- Associar a `LabRole` aos Managed Node Groups.
- Usar `data "aws_iam_role"` ou variável para referenciar a `LabRole`.
- Não executar `terraform plan` ou `terraform apply` antes de abrir o AWS Academy Lab.
- Não salvar credenciais AWS no repositório.
- Não versionar `terraform.tfvars` real.
- Não versionar `terraform.tfstate`.
- Tratar Secrets Manager como Plano A, sujeito às permissões do Academy.
- Prever fallback com Kubernetes Secret gerado por script local, sem versionar valores reais.

## Consequências

A arquitetura será compatível com o ambiente acadêmico.

Alguns padrões profissionais, como IRSA, OIDC avançado, Karpenter ou KEDA, podem ser evitados ou documentados como limitação caso dependam de permissões IAM indisponíveis.

Para escalabilidade, a alternativa inicial segura será HPA por CPU.

## Critério de validação offline

Antes de conectar na AWS, a Fase 3 deve ter:

- estrutura Terraform criada;
- módulos básicos criados;
- ambiente `dev` criado;
- arquivos `.example` para backend e tfvars;
- README atualizado;
- ADRs registradas;
- scripts locais de validação;
- nenhuma credencial real versionada.
