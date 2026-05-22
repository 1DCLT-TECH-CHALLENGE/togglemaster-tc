# Fase 3 - AWS Academy - BLOCO AWS-08 - Untaint do EKS e novo plan do node group

Data: 2026-05-22

## Objetivo

Registrar a recuperação correta após o timeout do primeiro `terraform apply` no EKS.

## Contexto

O primeiro `terraform apply` falhou por timeout de 30 minutos aguardando o cluster EKS ficar `ACTIVE`.

Após o timeout, a AWS continuou a criação do cluster e o EKS mudou para `ACTIVE`.

O Terraform havia marcado `module.eks.aws_eks_cluster.this` como tainted, o que fazia o plan propor destruição e recriação do cluster.

## Ação corretiva

Foi confirmado que o cluster real estava saudável:

- cluster: `togglemaster-dev-eks`;
- status: `ACTIVE`;
- role: `arn:aws:iam::590183666984:role/LabRole`.

Como o recurso real estava saudável, foi executado:

```bash
terraform -chdir=fase3/terraform/environments/dev untaint module.eks.aws_eks_cluster.this
```

## Resultado do untaint

O Terraform retornou:

```text
Resource instance module.eks.aws_eks_cluster.this has been successfully untainted.
```

## Novo plan após untaint

Foi gerado novo plan, descartando o plano antigo consumido parcialmente.

Arquivos locais gerados em `fase3/logs/`:

- plan binário: `fase3/logs/fase3-dev-after-untaint-20260522-204421.tfplan`
- log do plan: `fase3/logs/fase3-dev-after-untaint-20260522-204421-plan.log`
- plan em texto: `fase3/logs/fase3-dev-after-untaint-20260522-204421-plan.txt`

Resultado:

- `PLAN_RC=0`
- `Plan: 1 to add, 0 to change, 0 to destroy.`

## Recurso restante planejado

O único recurso restante no plan é:

- `module.eks.aws_eks_node_group.default`

## Interpretação

O cluster EKS não será destruído nem recriado.

A continuação correta é aplicar o novo plan após untaint para criar apenas o Managed Node Group.

## O que NÃO foi executado

Não foi executado:

- `terraform apply` do novo plan;
- `terraform destroy`;
- alteração manual no console AWS;
- criação manual de node group.

## Status

Recuperação pós-timeout concluída.

Próximo passo: aplicar o novo plan controlado para criar o EKS Managed Node Group.
