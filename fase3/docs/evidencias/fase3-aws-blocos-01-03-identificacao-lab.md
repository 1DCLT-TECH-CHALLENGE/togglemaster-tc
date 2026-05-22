# Fase 3 - AWS Academy - Blocos AWS-01 a AWS-03

Data: 2026-05-22

## Objetivo

Registrar a identificação inicial do AWS Academy Lab e a validação preliminar da `LabRole`.

## AWS-01 - Identificação segura do Lab

Resultados:

- Git limpo antes de iniciar AWS;
- credenciais temporárias carregadas no terminal sem versionamento;
- `aws sts get-caller-identity` executado com sucesso;
- conta AWS identificada: `590183666984`;
- sessão atual: `assumed-role/voclabs`;
- `LabRole` encontrada com sucesso.

LabRole:

- `arn:aws:iam::590183666984:role/LabRole`

## AWS-02 - Região e chamadas read-only

Região definida para a sessão:

- `us-east-1`

Availability Zones disponíveis:

- `us-east-1a`
- `us-east-1b`
- `us-east-1c`
- `us-east-1d`
- `us-east-1e`
- `us-east-1f`

Serviços consultados via chamadas read-only:

- ECR: sem repositórios;
- DynamoDB: sem tabelas;
- RDS: sem instâncias;
- ElastiCache: sem clusters;
- EKS: sem clusters.

## Políticas anexadas à LabRole

Foram listadas policies anexadas à `LabRole`, incluindo:

- `AmazonSSMManagedInstanceCore`
- `AmazonEKSClusterPolicy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonEKSWorkerNodePolicy`
- `VocLabPolicy1`
- `VocLabPolicy2`
- `VocLabPolicy3`

## AWS-03 - Limitação de inspeção de policies

A tentativa de inspecionar o conteúdo das policies customer-managed do Lab retornou `AccessDenied`.

Erro observado:

- `iam:GetPolicy` negado explicitamente por policy `Pvoclabs1`.

Interpretação:

- o AWS Academy permite listar policies anexadas à `LabRole`;
- o AWS Academy não permite abrir o documento das `VocLabPolicy*`;
- a validação de permissões precisará ocorrer por probes controlados e por `terraform plan` em etapa posterior, não por leitura direta das policies.

## O que NÃO foi executado

Não foi executado:

- `terraform plan`;
- `terraform apply`;
- `terraform destroy`;
- `kubectl apply`;
- `helm install`;
- `helm upgrade`;
- push de imagem para ECR real;
- deploy real em EKS.

## Status

Lab identificado com sucesso.

Limitação de inspeção IAM documentada.

Próxima etapa: validações controladas de capacidade/permissões antes do primeiro `terraform plan`.
