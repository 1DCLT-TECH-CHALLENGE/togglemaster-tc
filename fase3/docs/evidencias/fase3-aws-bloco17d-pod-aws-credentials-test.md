# Fase 3 - AWS Academy - BLOCO AWS-17D - Teste de credenciais AWS a partir de pod no EKS

Data: 2026-05-22

## Objetivo

Validar se um pod executando dentro do cluster EKS conseguiria acessar AWS automaticamente usando credenciais herdadas do ambiente, node role ou metadata service.

Esse teste foi realizado antes de definir a estratégia final de runtime/secrets, para evitar assumir que os microsserviços teriam acesso direto a SQS, DynamoDB ou Secrets Manager sem configuração adicional.

## Teste executado

Foi criado um pod efêmero com a imagem:

- amazon/aws-cli:2.15.30

Comandos executados dentro do pod:

- aws --version
- aws sts get-caller-identity --region us-east-1
- aws secretsmanager list-secrets --region us-east-1 --max-results 5

## Resultado

O pod foi criado e removido corretamente.

O teste retornou:

- Unable to locate credentials

Tanto para:

- sts get-caller-identity;
- secretsmanager list-secrets.

## Interpretação

Os pods do cluster EKS, no estado atual, não possuem credenciais AWS disponíveis automaticamente.

Portanto, não é seguro assumir que analytics-service e evaluation-service conseguirão acessar SQS, DynamoDB ou Secrets Manager apenas por estarem executando no EKS.

## Impacto

O deploy real dos microsserviços continua bloqueado até a definição de uma solução segura para:

- DATABASE_URL;
- MASTER_KEY;
- SERVICE_API_KEY;
- acesso AWS necessário para SQS/DynamoDB;
- eventual acesso a Secrets Manager.

## Decisão

Não aplicar os manifests no cluster neste momento.

A próxima etapa deve avaliar uma solução compatível com AWS Academy/LabRole, evitando hardcode de access keys, secret keys, tokens, senhas ou API keys no Git.

## Git

O repositório permaneceu limpo após o teste.

## Status

BLOCO AWS-17D concluído com sucesso.
