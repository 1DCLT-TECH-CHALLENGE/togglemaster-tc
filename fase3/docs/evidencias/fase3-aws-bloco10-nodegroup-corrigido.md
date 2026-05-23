# Fase 3 - AWS Academy - BLOCO AWS-10 - EKS Node Group corrigido e funcional

Data: 2026-05-22

## Objetivo

Registrar a correção definitiva do EKS Managed Node Group após a falha NodeCreationFailure.

## Contexto

O primeiro node group falhou porque as instâncias EC2 foram criadas, mas não conseguiram entrar no cluster Kubernetes.

Erro observado anteriormente:

NodeCreationFailure: Instances failed to join the kubernetes cluster

## Causa diagnosticada

O Managed Node Group usava Launch Template com Security Group customizado nos nodes.

O Launch Template dos nodes estava usando apenas o Security Group customizado dos nodes. Com isso, o cluster security group gerado pelo EKS não estava anexado às instâncias.

## Correção aplicada

O módulo Terraform eks foi ajustado para anexar também o cluster security group gerado pelo EKS no Launch Template dos nodes.

Arquivo alterado:

- fase3/terraform/modules/eks/main.tf

Trecho corrigido:

vpc_security_group_ids = [
  var.node_security_group_id,
  aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
]

Também foi mantido depends_on explícito entre cluster, launch template e node group.

## Apply executado

Foi aplicado o plan corrigido:

- fase3/logs/fase3-dev-fix-node-sg-20260522-213524.tfplan

Resultado:

- Apply complete! Resources: 1 added, 1 changed, 1 destroyed.
- APPLY_RC=0

## Resultado AWS

Cluster EKS:

- togglemaster-dev-eks: ACTIVE

Node group:

- togglemaster-dev-default-ng: ACTIVE
- instance type: t3.small
- desired size: 2
- min size: 1
- max size: 3

## Resultado Kubernetes

Nodes registrados e Ready:

- ip-10-10-43-135.ec2.internal
- ip-10-10-54-77.ec2.internal

Pods kube-system validados em Running:

- aws-node
- kube-proxy
- coredns

## Interpretação

A falha anterior não era problema de criação de EC2. O problema era o registro dos nodes no Kubernetes.

Após anexar o cluster security group gerado pelo EKS ao Launch Template dos nodes, o node group foi recriado com sucesso e os nodes entraram no cluster.

## Status

BLOCO AWS-10 concluído com sucesso.
