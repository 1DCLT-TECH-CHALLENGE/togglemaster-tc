# Fase 3 - AWS Academy - BLOCO AWS-09 - Falha no EKS Managed Node Group

Data: 2026-05-22

## Objetivo

Registrar a falha do apply controlado do EKS Managed Node Group.

## Contexto

Após o timeout inicial do cluster EKS e posterior recuperação via `terraform untaint`, foi gerado um novo plan seguro:

- `Plan: 1 to add, 0 to change, 0 to destroy.`

Esse plan criava apenas:

- `module.eks.aws_eks_node_group.default`

## Resultado do apply

O apply do node group falhou.

Log local:

- `fase3/logs/fase3-dev-nodegroup-20260522-204730-apply.log`

Erro observado:

```text
NodeCreationFailure: Instances failed to join the kubernetes cluster
```

## Estado observado

As instâncias EC2 do Auto Scaling Group foram criadas e chegaram a ficar `running`, mas não apareceram como nodes no Kubernetes.

Resultado observado em `kubectl get nodes`:

```text
No resources found
```

## Interpretação inicial

A falha não é de criação de EC2.

A falha é no bootstrap/registro dos nodes no EKS.

O principal suspeito técnico é comunicação incompleta entre o Security Group customizado dos nodes e o Security Group gerado pelo EKS cluster.

Como o Managed Node Group usa Launch Template com Security Group customizado, o EKS não adiciona automaticamente o cluster security group nas instâncias. Portanto, as regras entre control plane e nodes precisam ser declaradas explicitamente no Terraform.

## O que NÃO foi feito

Não foi executado:

- `terraform destroy`;
- novo `terraform apply`;
- deleção manual no console AWS;
- criação manual de node group;
- alteração manual de security group no console.

## Próximo passo

Corrigir as regras de Security Group via Terraform, tratar o node group em estado `CREATE_FAILED` de forma controlada e gerar novo plan antes de qualquer apply.
