# Fase 3 - BLOCO 11 - Módulo ElastiCache Redis offline

Data: 2026-05-22

## Objetivo

Criar e conectar o módulo Terraform de ElastiCache Redis da Fase 3, ainda sem conexão com AWS.

## Contexto

Na Fase 2 local, o `evaluation-service` usa Redis em container para cache de avaliações.

Na Fase 3, esse Redis será modelado como ElastiCache Redis via Terraform.

## Recursos modelados

- `aws_elasticache_subnet_group`;
- `aws_elasticache_replication_group`;
- Security Group recebido do módulo `security`;
- subnets privadas recebidas do módulo `networking`;
- criptografia em repouso habilitada por padrão;
- endpoint e porta exportados via outputs.

## Decisão inicial para AWS Academy

O módulo começa com:

- `num_cache_clusters = 1`;
- `automatic_failover_enabled = false`;
- `node_type = cache.t3.micro`;
- `transit_encryption_enabled = false`.

Esses defaults reduzem complexidade para o ambiente dev/Academy.

Antes de `terraform plan/apply`, validar no AWS Academy se a classe `cache.t3.micro` e a versão Redis definida estão disponíveis.

## Ambiente dev

O módulo `elasticache` foi conectado em:

- `terraform/environments/dev/main.tf`

Outputs adicionados em:

- `terraform/environments/dev/outputs.tf`

## Restrições respeitadas

Não foi executado:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- criação de recursos AWS;
- login no AWS Academy.

## Status

Módulo ElastiCache Redis criado e conectado ao ambiente `dev` para validação local posterior.
