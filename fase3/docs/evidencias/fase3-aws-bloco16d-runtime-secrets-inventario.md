# Fase 3 - AWS Academy - BLOCO AWS-16D - Inventário seguro de runtime e secrets

Data: 2026-05-22

## Objetivo

Registrar o inventário seguro das configurações de runtime necessárias antes de qualquer deploy real dos microsserviços no EKS.

## Segurança

O bloco foi executado sem imprimir valores reais de segredo.

Foram coletados apenas:

- endpoints;
- nomes de recursos;
- ARNs de secrets;
- metadados de secrets;
- referências existentes nos manifests GitOps.

## Credenciais AWS

As credenciais temporárias da sessão estavam carregadas na VM:

- AWS_ACCESS_KEY_ID presente;
- AWS_SECRET_ACCESS_KEY presente;
- AWS_SESSION_TOKEN presente.

A identidade AWS foi validada na conta:

- 590183666984

Sessão:

- assumed-role/voclabs

## Outputs Terraform não sensíveis

Foram confirmados:

- endpoints RDS para auth, flags e targeting;
- endpoint Redis;
- URL da fila SQS;
- nome da tabela DynamoDB.

## RDS

As três instâncias RDS PostgreSQL estavam disponíveis:

- togglemaster-dev-auth-postgres
- togglemaster-dev-flags-postgres
- togglemaster-dev-targeting-postgres

Também foram confirmados os ARNs dos secrets gerenciados pelo RDS no Secrets Manager, sem leitura dos valores secretos.

## Secrets Manager

Foram encontrados secrets metadata do ToggleMaster:

- togglemaster-dev/auth-service-config
- togglemaster-dev/flag-service-config
- togglemaster-dev/targeting-service-config
- togglemaster-dev/evaluation-service-config
- togglemaster-dev/analytics-service-config

Observação importante:

Os secrets de configuração do ToggleMaster existem como metadados, mas o valor real não é definido pelo Terraform neste módulo.

## Manifests GitOps atuais

Os manifests GitOps atualmente usam envFrom com ConfigMap:

- auth-service
- flag-service
- targeting-service
- evaluation-service
- analytics-service

Ainda não há secretRef, secretKeyRef ou mecanismo equivalente nos manifests para entregar DATABASE_URL, SERVICE_API_KEY ou demais variáveis sensíveis.

## Interpretação

A infraestrutura necessária existe, mas os manifests ainda não devem ser aplicados no cluster.

Antes do deploy real, será necessário definir uma solução segura para runtime config e secrets, evitando hardcode de senhas, tokens ou chaves nos manifests Kubernetes.

## Status

BLOCO AWS-16D concluído com sucesso.
