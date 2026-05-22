# Matriz operacional de responsabilidades dos bootstraps

Data: 2026-05-22

## Objetivo

Definir claramente o que cada bootstrap deve fazer e o que não deve fazer.

Essa matriz evita mistura de responsabilidades entre fases.

## Matriz resumida

| Bootstrap | Responsabilidade principal | Pode criar estrutura? | Pode subir serviços? | Pode acessar AWS? | Observação |
|---|---|---:|---:|---:|---|
| 00_prepare_vm.sh | Preparar VM e ferramentas base | Sim | Não | Não | Fundação comum |
| 01_bootstrap_fase1.sh | Subir e validar Fase 1 | Sim | Sim | Não | Monólito local |
| 02_bootstrap_fase2.sh | Subir e validar Fase 2 local | Sim | Sim | Não | Microsserviços + LocalStack |
| 03_bootstrap_fase3.sh | Criar IaC/GitOps/DevSecOps | Sim | Não deve recriar Fase 2 | Sim, somente quando autorizado | AWS Academy + LabRole |
| 04_bootstrap_fase4.sh | Subir observabilidade/APM/incidentes | Sim | Sim, apenas componentes Fase 4 | Sim, se necessário e autorizado | Assume Fase 2/3 prontas |
| 99_validate_all.sh | Validar estado geral | Não necessariamente | Não necessariamente | Não por padrão | Orquestra validações |

## Fase 1

Entrada esperada:

- VM preparada;
- Docker disponível;
- Git disponível.

Saída esperada:

- monólito local subindo;
- testes locais executados;
- evidências geradas.

## Fase 2

Entrada esperada:

- VM preparada;
- Docker disponível;
- Go/Python disponíveis;
- estrutura raiz existente.

Saída esperada:

- cinco microsserviços locais;
- PostgreSQL local;
- Redis local;
- LocalStack;
- SQS local;
- DynamoDB local;
- fluxo E2E validado;
- evidências geradas.

## Fase 3

Não deve recriar código/containers locais da Fase 2.

Entrada esperada:

- Fase 2 versionada;
- estrutura raiz existente;
- Terraform instalado;
- kubectl/Helm/AWS CLI instalados;
- AWS Academy ainda não necessariamente conectado.

Saída esperada offline:

- Terraform estruturado;
- módulos criados;
- GitOps criado;
- workflows criados;
- terraform fmt;
- terraform init -backend=false;
- terraform validate;
- evidências offline.

Saída esperada com AWS Academy:

- backend remoto definido;
- infraestrutura AWS criada por Terraform;
- EKS provisionado com LabRole;
- ECR, RDS, Redis, SQS e DynamoDB provisionados;
- deploy preparado via GitOps.

## Fase 4

Não deve reconstruir Fase 2 ou Fase 3.

Entrada esperada:

- Fase 2 funcional;
- Fase 3 provisionada;
- cluster e workloads disponíveis.

Saída esperada:

- observabilidade;
- métricas;
- logs;
- traces;
- dashboards;
- alertas;
- ChatOps;
- automações de resposta;
- evidências.

## Critério final de aceite

O rebuild será considerado completo quando:

1. cada fase possuir bootstrap próprio;
2. cada bootstrap for reexecutável;
3. cada fase tiver evidências;
4. o repositório GitHub estiver atualizado;
5. não houver criação manual obrigatória fora dos pontos explicitamente documentados;
6. AWS Academy for usado apenas quando necessário e com LabRole;
7. a Fase 4 estiver implantada sobre a base das Fases 2 e 3.
