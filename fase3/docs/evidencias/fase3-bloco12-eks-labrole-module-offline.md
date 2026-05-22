# Fase 3 - BLOCO 12 - Módulo EKS com LabRole offline

Data: 2026-05-22

## Objetivo

Criar e conectar o módulo Terraform de EKS da Fase 3, ainda sem conexão com AWS.

## Contexto AWS Academy

O ambiente alvo é AWS Academy Lab.

A regra principal é usar a IAM Role existente `LabRole`.

## Decisão de implementação

O módulo EKS usa:

- `data "aws_iam_role" "lab_role"`;
- `role_arn = data.aws_iam_role.lab_role.arn` no `aws_eks_cluster`;
- `node_role_arn = data.aws_iam_role.lab_role.arn` no `aws_eks_node_group`.

## Recursos modelados

- `aws_eks_cluster`;
- `aws_launch_template` para aplicar Security Group aos nodes;
- `aws_eks_node_group` gerenciado;
- outputs do cluster, node group e LabRole ARN.

## O que NÃO foi feito

Não foi criado:

- IAM Role nova;
- IAM Policy nova;
- IRSA;
- OIDC provider;
- Karpenter;
- KEDA;
- recurso AWS real.

## Ponto de atenção para o AWS Academy

Antes de `terraform plan/apply`, validar no Lab:

- se a `LabRole` existe com esse nome;
- se a `LabRole` pode ser usada por EKS Cluster;
- se a `LabRole` pode ser usada por Managed Node Group;
- se a versão Kubernetes `1.30` está disponível;
- se `t3.small` está disponível;
- se a combinação LabRole + EKS é aceita pelo Academy.

## Restrições respeitadas

Não foi executado:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- login no AWS Academy.

## Status

Módulo EKS criado e conectado ao ambiente `dev` para validação local posterior.

## Correção pós-criação

Após revisão técnica, foi removido `disk_size` do `aws_eks_node_group`, porque `disk_size` conflita com o uso de `launch_template`.

A configuração de disco dos nodes foi movida para o `aws_launch_template.nodes` usando `block_device_mappings` com:

- `device_name = "/dev/xvda"`;
- `volume_size = var.node_disk_size`;
- `volume_type = "gp3"`;
- `encrypted = true`.

Essa correção preserva o uso do Security Group customizado dos nodes e evita conflito no Terraform.
