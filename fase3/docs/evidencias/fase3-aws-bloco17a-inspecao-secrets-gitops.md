# Fase 3 - AWS Academy - BLOCO AWS-17A - Inspeção da base de secrets/IAM/GitOps

Data: 2026-05-22

## Objetivo

Registrar a inspeção da base existente de secrets, IAM, GitOps e cluster antes de definir a estratégia definitiva de runtime/secrets para deploy dos microsserviços.

## Resultado da inspeção

A inspeção confirmou que:

- o módulo Terraform `secrets` cria apenas metadados no AWS Secrets Manager;
- os valores reais dos secrets de aplicação não são definidos pelo Terraform;
- os RDS PostgreSQL possuem secrets gerenciados pelo próprio RDS no AWS Secrets Manager;
- os manifests GitOps atuais usam apenas `envFrom` com ConfigMap;
- ainda não há `secretRef`, `secretKeyRef`, `ExternalSecret`, `SecretProviderClass` ou Kubernetes Secret declarados nos manifests;
- não há CRDs de External Secrets ou Secrets Store CSI Driver instalados no cluster;
- o cluster possui apenas os namespaces padrão;
- o repositório permaneceu limpo após a inspeção.

## GitOps atual

Os manifests base já apontam para imagens reais do ECR com a tag `c0f03bb`.

Porém, a configuração de runtime ainda é incompleta para deploy real dos microsserviços, pois variáveis sensíveis e obrigatórias como `DATABASE_URL` e `SERVICE_API_KEY` ainda não possuem mecanismo seguro de entrega ao pod.

## Decisão

Não aplicar os manifests no cluster neste momento.

Antes do deploy real, será necessário definir e implementar uma solução segura para runtime/secrets, evitando hardcode de senhas, tokens ou API keys no Git.

## Status

BLOCO AWS-17A concluído com sucesso.
