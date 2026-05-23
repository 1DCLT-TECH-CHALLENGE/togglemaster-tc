# Fase 3 - AWS Academy - Sanity check pós AWS-10

Data: 2026-05-22

## Objetivo

Registrar a validação final do cluster EKS após a correção do Managed Node Group no BLOCO AWS-10.

## Resultado Git

O repositório estava limpo e sincronizado com origin/main.

Último commit validado:

- f5d7e80 docs: record fixed eks nodegroup validation

## Resultado EKS

Cluster validado:

- nome: togglemaster-dev-eks
- status: ACTIVE
- região: us-east-1

Node group validado:

- nome: togglemaster-dev-default-ng
- status: ACTIVE
- instância: t3.small
- desired size: 2
- min size: 1
- max size: 3

## Resultado Kubernetes

Nodes registrados e Ready:

- ip-10-10-43-135.ec2.internal
- ip-10-10-54-77.ec2.internal

Pods kube-system em Running:

- aws-node
- kube-proxy
- coredns

## Interpretação

A correção aplicada no Launch Template dos nodes resolveu o problema de registro dos workers no cluster.

O cluster EKS está pronto para os próximos blocos da Fase 3, incluindo validações GitOps, ArgoCD e deploy dos microsserviços.

## Status

Sanity check pós-AWS-10 concluído com sucesso.
