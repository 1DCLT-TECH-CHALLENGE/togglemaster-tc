# Fase 3 - AWS Academy - BLOCO AWS-17E - Diagnóstico de credenciais AWS para pods

Data: 2026-05-22

## Objetivo

Registrar o diagnóstico read-only sobre caminhos possíveis para fornecer credenciais AWS aos pods no EKS.

Este bloco foi executado após o teste AWS-17D, no qual um pod efêmero com AWS CLI não conseguiu executar chamadas AWS por ausência de credenciais.

## Resultado do diagnóstico

Foram verificados:

- credenciais locais da VM;
- identidade AWS local;
- OIDC issuer do cluster EKS;
- IAM OIDC providers existentes na conta;
- Launch Template do node group;
- MetadataOptions das instâncias EC2 dos nodes;
- IAM instance profile dos nodes;
- ServiceAccounts existentes no cluster;
- estado do Git.

## OIDC

O cluster EKS possui OIDC issuer:

- https://oidc.eks.us-east-1.amazonaws.com/id/47AAFA7006C0C5399AC8F2CE4704EEC7

Porém, a conta AWS não retornou nenhum IAM OIDC provider configurado.

Interpretação:

- IRSA não está configurado no estado atual.

## Nodes EC2

As instâncias EC2 do node group estão running e possuem IAM instance profile associado.

Porém, as MetadataOptions dos nodes indicaram:

- HttpTokens: required
- HttpEndpoint: enabled
- HttpPutResponseHopLimit: 1

Interpretação:

- os nodes possuem IAM instance profile;
- porém, com HopLimit 1, não é seguro assumir que pods consigam acessar credenciais do IMDS do node;
- isso é consistente com o teste anterior em que o pod AWS CLI retornou `Unable to locate credentials`.

## ServiceAccounts

Foram encontrados apenas ServiceAccounts padrão do cluster.

Não há ServiceAccount de aplicação anotada para IRSA.

## Impacto

No estado atual, os pods não têm um caminho automático validado para acessar:

- SQS;
- DynamoDB;
- Secrets Manager.

Portanto, analytics-service e evaluation-service não devem ser implantados assumindo credenciais AWS automáticas.

## Decisão

Não aplicar manifests no cluster ainda.

A próxima etapa deve avaliar uma estratégia compatível com AWS Academy/LabRole para runtime/secrets, considerando:

- criação de IAM OIDC provider e IRSA, se permitido;
- instalação de External Secrets ou Secrets Store CSI, se permitido;
- alternativa operacional controlada sem hardcode de secrets no Git, caso as permissões do Lab bloqueiem a abordagem ideal.

## Git

O repositório permaneceu limpo após a inspeção.

## Status

BLOCO AWS-17E concluído com sucesso.
