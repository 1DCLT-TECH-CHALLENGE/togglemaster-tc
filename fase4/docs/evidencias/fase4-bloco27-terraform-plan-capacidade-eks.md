# Fase 4 - BLOCO 27 - Terraform Plan da Correção de Capacidade do EKS

Data: Sat May 23 03:04:06 PM -03 2026

## Objetivo

Gerar e revisar o `terraform plan` da correção de capacidade do EKS antes de qualquer `terraform apply`.

Este bloco:

- executa `terraform plan -detailed-exitcode`;
- salva o plano binário apenas em diretório temporário não versionado;
- registra saída textual redigida;
- não executa `terraform apply`;
- não altera recursos AWS.


## 1. Estado Git inicial


### Git status

```bash
$ git status --short
?? fase4/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks.md
?? fase4/scripts/27_terraform_plan_eks_capacity.sh

```

RC: `0`

### Últimos commits

```bash
$ git log --oneline --decorate -8
d75514c (HEAD -> main, origin/main) feat: adjust eks capacity for phase 4 observability
72bb291 docs: plan phase 4 observability capacity fix
7d6f15d docs: record phase 4 observability capacity gate
4680d8b docs: record phase 4 stack inventory
74f1c33 docs: open phase 4 delivery
0d26f9f docs: add pre phase 4 readiness gate
e38cf8d fix: prevent phase 2 e2e from persisting runtime api key
d7666dd docs: record phase 2 local pre phase 4 revalidation

```

RC: `0`
- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 27.

## 2. Pré-checks AWS/Terraform


### AWS identity

```bash
$ aws sts get-caller-identity --output table
------------------------------------------------------------------------------------------------
|                                       GetCallerIdentity                                      |
+---------+------------------------------------------------------------------------------------+
|  Account|  590183666984                                                                      |
|  Arn    |  arn:aws:sts::590183666984:assumed-role/voclabs/user4447841=wellk.well@gmail.com   |
|  UserId |  AROAYS2NQCUUFEE2UOXGE:user4447841=wellk.well@gmail.com                            |
+---------+------------------------------------------------------------------------------------+

```

RC: `0`

### Terraform version

```bash
$ terraform version
Terraform v1.15.3
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.15.4. You can update by downloading from https://developer.hashicorp.com/terraform/install

```

RC: `0`

### Terraform init

```bash
$ terraform -chdir=fase3/terraform/environments/dev init
[0m[1mInitializing modules...[0m
[0m[1mInitializing provider plugins found in the configuration...[0m
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/kubernetes from the dependency lock file
- Reusing previous version of hashicorp/helm from the dependency lock file
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/random v3.9.0
- Using previously-installed hashicorp/kubernetes v3.1.0
- Using previously-installed hashicorp/helm v3.1.2
- Using previously-installed hashicorp/aws v6.46.0

[0m[1mInitializing the backend...[0m

[0m[1mInitializing provider plugins found in the state...[0m
- Reusing previous version of hashicorp/aws
- Using previously-installed hashicorp/aws v6.46.0


[0m[1m[32mTerraform has been successfully initialized![0m[32m[0m
[0m[32m
You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.[0m

```

RC: `0`

### Terraform validate

```bash
$ terraform -chdir=fase3/terraform/environments/dev validate
[32m[1mSuccess![0m The configuration is valid.
[0m

```

RC: `0`

## 3. Confirmar IaC desejado


### Valores EKS em main.tf

```bash
$ bash -lc grep -nE 'module "eks"|node_instance_types|node_min_size|node_desired_size|node_max_size' fase3/terraform/environments/dev/main.tf
75:module "eks" {
84:  node_instance_types                  = ["t3.small"]
85:  node_min_size                        = 2
86:  node_desired_size                    = 5
87:  node_max_size                        = 5

```

RC: `0`

### Nodegroup atual na AWS

```bash
$ aws eks describe-nodegroup --cluster-name togglemaster-dev-eks --nodegroup-name togglemaster-dev-default-ng --region us-east-1 --query nodegroup.{nodegroupName:nodegroupName,status:status,instanceTypes:instanceTypes,scalingConfig:scalingConfig} --output table
-------------------------------------------
|            DescribeNodegroup            |
+-------------------------------+---------+
|         nodegroupName         | status  |
+-------------------------------+---------+
|  togglemaster-dev-default-ng  |  ACTIVE |
+-------------------------------+---------+
||             instanceTypes             ||
|+---------------------------------------+|
||  t3.small                             ||
|+---------------------------------------+|
||             scalingConfig             ||
|+---------------+-----------+-----------+|
||  desiredSize  |  maxSize  |  minSize  ||
|+---------------+-----------+-----------+|
||  2            |  3        |  1        ||
|+---------------+-----------+-----------+|

```

RC: `0`

## 4. Terraform plan


### Terraform plan redigido

```text
module.secrets.aws_secretsmanager_secret.this["flag-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/flag-service-config-Z3wpKA]
module.ecr.aws_ecr_repository.this["analytics-service"]: Refreshing state... [id=togglemaster-dev/analytics-service]
module.sqs.aws_sqs_queue.events: Refreshing state... [id=https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events]
module.ecr.aws_ecr_repository.this["auth-service"]: Refreshing state... [id=togglemaster-dev/auth-service]
module.networking.aws_vpc.this: Refreshing state... [id=vpc-06345e59392ca4c9f]
module.eks.data.aws_iam_role.lab_role: Reading...
module.secrets.aws_secretsmanager_secret.this["targeting-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/targeting-service-config-9ce5Aa]
module.ecr.aws_ecr_repository.this["evaluation-service"]: Refreshing state... [id=togglemaster-dev/evaluation-service]
module.ecr.aws_ecr_repository.this["flag-service"]: Refreshing state... [id=togglemaster-dev/flag-service]
module.ecr.aws_ecr_repository.this["targeting-service"]: Refreshing state... [id=togglemaster-dev/targeting-service]
module.eks.data.aws_iam_role.lab_role: Read complete after 1s [id=LabRole]
module.dynamodb.aws_dynamodb_table.analytics: Refreshing state... [id=togglemaster-dev-ToggleMasterAnalytics]
module.secrets.aws_secretsmanager_secret.this["analytics-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/analytics-service-config-fATRk3]
module.secrets.aws_secretsmanager_secret.this["auth-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/auth-service-config-vjqbDo]
module.secrets.aws_secretsmanager_secret.this["evaluation-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/evaluation-service-config-3Zr7s1]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["flag-service"]: Refreshing state... [id=togglemaster-dev/flag-service]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["evaluation-service"]: Refreshing state... [id=togglemaster-dev/evaluation-service]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["targeting-service"]: Refreshing state... [id=togglemaster-dev/targeting-service]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["analytics-service"]: Refreshing state... [id=togglemaster-dev/analytics-service]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["auth-service"]: Refreshing state... [id=togglemaster-dev/auth-service]
module.networking.aws_internet_gateway.this: Refreshing state... [id=igw-0a69a1a521a03c781]
module.networking.aws_subnet.public[1]: Refreshing state... [id=subnet-050e369beec248a7a]
module.networking.aws_subnet.public[0]: Refreshing state... [id=subnet-0b359eccd433dba23]
module.networking.aws_route_table.public: Refreshing state... [id=rtb-06f186be3f25dc6d2]
module.networking.aws_subnet.private[0]: Refreshing state... [id=subnet-05716f18fbd129998]
module.networking.aws_subnet.private[1]: Refreshing state... [id=subnet-0f7f578133c62abd4]
module.security.aws_security_group.eks_cluster_additional: Refreshing state... [id=sg-0ec55ac590f25f604]
module.security.aws_security_group.alb: Refreshing state... [id=sg-0bacf8e9e3cf22cf3]
module.networking.aws_route.public_default_ipv4: Refreshing state... [id=r-rtb-06f186be3f25dc6d21080289494]
module.security.aws_security_group.eks_nodes: Refreshing state... [id=sg-077f0782621a7b63f]
module.networking.aws_route_table.private[0]: Refreshing state... [id=rtb-05ef29396bf3c0ad1]
module.rds.aws_db_subnet_group.this: Refreshing state... [id=togglemaster-dev-rds-subnet-group]
module.eks.aws_eks_cluster.this: Refreshing state... [id=togglemaster-dev-eks]
module.networking.aws_route_table.private[1]: Refreshing state... [id=rtb-09b586bbcb4e2df4d]
module.elasticache.aws_elasticache_subnet_group.this: Refreshing state... [id=togglemaster-dev-redis-subnet-group]
module.networking.aws_route_table_association.public[0]: Refreshing state... [id=rtbassoc-042d4e7fae1392f8c]
module.networking.aws_route_table_association.public[1]: Refreshing state... [id=rtbassoc-04aeb0d3d9944e8fc]
module.networking.aws_eip.nat[0]: Refreshing state... [id=eipalloc-083912e2b9aaf8647]
module.security.aws_security_group.rds: Refreshing state... [id=sg-08e10e08992448282]
module.security.aws_security_group.redis: Refreshing state... [id=sg-03fb32147f4a39d81]
module.networking.aws_route_table_association.private[0]: Refreshing state... [id=rtbassoc-0870e81cca8f64b3a]
module.networking.aws_route_table_association.private[1]: Refreshing state... [id=rtbassoc-0058343a764e57a54]
module.networking.aws_nat_gateway.this[0]: Refreshing state... [id=nat-09259ed9bf4742b99]
module.eks.aws_launch_template.nodes: Refreshing state... [id=lt-0ed887d0100c82665]
module.networking.aws_route.private_default_nat[0]: Refreshing state... [id=r-rtb-05ef29396bf3c0ad11080289494]
module.networking.aws_route.private_default_nat[1]: Refreshing state... [id=r-rtb-09b586bbcb4e2df4d1080289494]
module.rds.aws_db_instance.postgres["flags"]: Refreshing state... [id=db-I4LQAGAXOOP56BWHC2P7G574LE]
module.rds.aws_db_instance.postgres["targeting"]: Refreshing state... [id=db-Z44PRD2CXMSJF6UT4R2DPYPQGE]
module.rds.aws_db_instance.postgres["auth"]: Refreshing state... [id=db-VKB2Q2LO353WL5MG55VHNDF264]
module.elasticache.aws_elasticache_replication_group.redis: Refreshing state... [id=togglemaster-dev-redis]
module.eks.aws_eks_node_group.default: Refreshing state... [id=togglemaster-dev-eks:togglemaster-dev-default-ng]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # module.eks.aws_eks_node_group.default will be updated in-place
  ~ resource "aws_eks_node_group" "default" {
        id                     = "togglemaster-dev-eks:togglemaster-dev-default-ng"
        tags                   = {
            "Course"      = "FIAP-Tech-Challenge"
            "Environment" = "dev"
            "ManagedBy"   = "Terraform"
            "Module"      = "eks"
            "Name"        = "togglemaster-dev-default-ng"
            "Project"     = "ToggleMaster"
        }
        # (17 unchanged attributes hidden)

      ~ scaling_config {
          ~ desired_size = 2 -> 5
          ~ max_size     = 3 -> 5
          ~ min_size     = 1 -> 2
        }

        # (3 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────

Saved the plan to:
/home/wellk/togglemaster-tc/fase4/tmp/bloco27/tfplan-capacity-fase4.bin

To perform exactly these actions, run the following command to apply:
    terraform apply "/home/wellk/togglemaster-tc/fase4/tmp/bloco27/tfplan-capacity-fase4.bin"

```

PLAN_RC: `2`

## 5. Análise automática do plano


### Análise automática do plano

```text
plan_adds=0
plan_changes=1
plan_destroys=0
actions_mentions_eks_node_group=True
actions_update_in_place=True
actions_desired_2_to_5=True
actions_max_3_to_5=True
actions_min_1_to_2=True
actions_replacement=False
actions_destroy_resource=False
actions_unexpected_rds=False
actions_unexpected_vpc=False
actions_unexpected_ecr=False
PLAN_REVIEW=PASS_AUTOMATED_REVIEW

```

ANALYSIS_RC: `0`

## 6. Segurança


### Check tfstate/tfvars versionados

```bash
$ bash -lc git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true

```

RC: `0`

## Segurança

O plano binário foi salvo em diretório temporário não versionado e não deve ser commitado.

Nenhum `tfstate`, `terraform.tfvars` real ou `*.auto.tfvars` está versionado.


## 7. Resultado


## Resultado

BLOCO 27 concluído com sucesso.

- `PLAN_RC=2`
- Análise automática: `PASS_AUTOMATED_REVIEW`
- Nenhum `terraform apply` foi executado.

Próximo bloco recomendado:

1. revisar a evidência do plano;
2. executar `terraform apply` em bloco separado;
3. validar EKS/nodegroup após apply;
4. reexecutar gate de capacidade.

