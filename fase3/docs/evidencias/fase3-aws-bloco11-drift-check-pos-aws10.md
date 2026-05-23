# Fase 3 - AWS Academy - BLOCO AWS-11 - Drift check pós AWS-10

Data: 2026-05-22

## Objetivo

Registrar a validação de idempotência do Terraform após a correção do EKS Managed Node Group.

## Contexto

Após o BLOCO AWS-10, o EKS cluster ficou ACTIVE, o Managed Node Group ficou ACTIVE, os nodes entraram como Ready e os pods kube-system ficaram Running.

Em seguida foi executado um drift check com:

terraform plan -no-color -detailed-exitcode

## Primeiro drift detectado

O primeiro drift check pós-AWS-10 retornou:

- PLAN_RC=2
- Plan: 0 to add, 1 to change, 0 to destroy

A mudança detectada era apenas:

launch_template.version = "2" -> "$Latest"

Não havia destruição, recriação ou alteração crítica de infraestrutura.

## Correção aplicada

O módulo Terraform eks foi ajustado para usar explicitamente a versão mais recente do Launch Template:

version = aws_launch_template.nodes.latest_version

Arquivo alterado:

- fase3/terraform/modules/eks/main.tf

## Validação final

Após a correção, foi executado novo drift check.

Resultado:

- PLAN_RC=0
- No changes. Your infrastructure matches the configuration.

## Interpretação

A infraestrutura AWS da Fase 3 ficou alinhada com o código Terraform.

O drift recorrente do Launch Template foi eliminado.

## Status

BLOCO AWS-11 concluído com sucesso.
