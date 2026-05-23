# Fase 4 - BLOCO 28 - Terraform Apply da Correção de Capacidade do EKS

Data: Sat May 23 03:06:20 PM -03 2026

## Objetivo

Executar a correção de capacidade do EKS para permitir a instalação segura da stack de observabilidade da Fase 4.

Este bloco:

- gera novo `terraform plan` antes do apply;
- valida automaticamente que o plano altera somente o node group EKS;
- executa `terraform apply`;
- aguarda node group `ACTIVE`;
- aguarda 5 nodes `Ready`;
- executa capacity check pós-apply;
- não instala Prometheus, Grafana, Loki ou OTel.


## 1. Estado Git inicial


### Git status

```bash
$ git status --short
?? fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md
?? fase4/scripts/28_terraform_apply_eks_capacity.sh

```

RC: `0`

### Últimos commits

```bash
$ git log --oneline --decorate -8
abe295a (HEAD -> main, origin/main) docs: record phase 4 eks capacity terraform plan
d75514c feat: adjust eks capacity for phase 4 observability
72bb291 docs: plan phase 4 observability capacity fix
7d6f15d docs: record phase 4 observability capacity gate
4680d8b docs: record phase 4 stack inventory
74f1c33 docs: open phase 4 delivery
0d26f9f docs: add pre phase 4 readiness gate
e38cf8d fix: prevent phase 2 e2e from persisting runtime api key

```

RC: `0`
- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 28.

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

### Terraform init

```bash
$ terraform -chdir=fase3/terraform/environments/dev init
[0m[1mInitializing modules...[0m
[0m[1mInitializing provider plugins found in the configuration...[0m
- Reusing previous version of hashicorp/kubernetes from the dependency lock file
- Reusing previous version of hashicorp/helm from the dependency lock file
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/kubernetes v3.1.0
- Using previously-installed hashicorp/helm v3.1.2
- Using previously-installed hashicorp/aws v6.46.0
- Using previously-installed hashicorp/random v3.9.0

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

### Nodegroup antes do apply

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

### Nodes antes do apply

```bash
$ kubectl get nodes -o wide
NAME                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-40-95.ec2.internal    Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.40.95    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-49-137.ec2.internal   Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.49.137   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown

```

RC: `0`

## 3. Novo Terraform plan pré-apply


### Terraform plan redigido pré-apply

```text
module.ecr.aws_ecr_repository.this["evaluation-service"]: Refreshing state... [id=togglemaster-dev/evaluation-service]
module.ecr.aws_ecr_repository.this["targeting-service"]: Refreshing state... [id=togglemaster-dev/targeting-service]
module.ecr.aws_ecr_repository.this["analytics-service"]: Refreshing state... [id=togglemaster-dev/analytics-service]
module.eks.data.aws_iam_role.lab_role: Reading...
module.sqs.aws_sqs_queue.events: Refreshing state... [id=https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events]
module.secrets.aws_secretsmanager_secret.this["analytics-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/analytics-service-config-fATRk3]
module.ecr.aws_ecr_repository.this["auth-service"]: Refreshing state... [id=togglemaster-dev/auth-service]
module.ecr.aws_ecr_repository.this["flag-service"]: Refreshing state... [id=togglemaster-dev/flag-service]
module.networking.aws_vpc.this: Refreshing state... [id=vpc-06345e59392ca4c9f]
module.secrets.aws_secretsmanager_secret.this["targeting-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/targeting-service-config-9ce5Aa]
module.secrets.aws_secretsmanager_secret.this["auth-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/auth-service-config-vjqbDo]
module.eks.data.aws_iam_role.lab_role: Read complete after 1s [id=LabRole]
module.secrets.aws_secretsmanager_secret.this["evaluation-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/evaluation-service-config-3Zr7s1]
module.secrets.aws_secretsmanager_secret.this["flag-service-config"]: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:590183666984:secret:togglemaster-dev/flag-service-config-Z3wpKA]
module.dynamodb.aws_dynamodb_table.analytics: Refreshing state... [id=togglemaster-dev-ToggleMasterAnalytics]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["analytics-service"]: Refreshing state... [id=togglemaster-dev/analytics-service]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["auth-service"]: Refreshing state... [id=togglemaster-dev/auth-service]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["flag-service"]: Refreshing state... [id=togglemaster-dev/flag-service]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["targeting-service"]: Refreshing state... [id=togglemaster-dev/targeting-service]
module.ecr.aws_ecr_lifecycle_policy.keep_last_images["evaluation-service"]: Refreshing state... [id=togglemaster-dev/evaluation-service]
module.networking.aws_subnet.private[1]: Refreshing state... [id=subnet-0f7f578133c62abd4]
module.networking.aws_subnet.public[0]: Refreshing state... [id=subnet-0b359eccd433dba23]
module.networking.aws_internet_gateway.this: Refreshing state... [id=igw-0a69a1a521a03c781]
module.networking.aws_subnet.private[0]: Refreshing state... [id=subnet-05716f18fbd129998]
module.networking.aws_subnet.public[1]: Refreshing state... [id=subnet-050e369beec248a7a]
module.networking.aws_route_table.public: Refreshing state... [id=rtb-06f186be3f25dc6d2]
module.security.aws_security_group.eks_cluster_additional: Refreshing state... [id=sg-0ec55ac590f25f604]
module.security.aws_security_group.alb: Refreshing state... [id=sg-0bacf8e9e3cf22cf3]
module.networking.aws_route.public_default_ipv4: Refreshing state... [id=r-rtb-06f186be3f25dc6d21080289494]
module.security.aws_security_group.eks_nodes: Refreshing state... [id=sg-077f0782621a7b63f]
module.networking.aws_route_table.private[0]: Refreshing state... [id=rtb-05ef29396bf3c0ad1]
module.eks.aws_eks_cluster.this: Refreshing state... [id=togglemaster-dev-eks]
module.rds.aws_db_subnet_group.this: Refreshing state... [id=togglemaster-dev-rds-subnet-group]
module.elasticache.aws_elasticache_subnet_group.this: Refreshing state... [id=togglemaster-dev-redis-subnet-group]
module.networking.aws_route_table.private[1]: Refreshing state... [id=rtb-09b586bbcb4e2df4d]
module.networking.aws_eip.nat[0]: Refreshing state... [id=eipalloc-083912e2b9aaf8647]
module.networking.aws_route_table_association.public[0]: Refreshing state... [id=rtbassoc-042d4e7fae1392f8c]
module.networking.aws_route_table_association.public[1]: Refreshing state... [id=rtbassoc-04aeb0d3d9944e8fc]
module.security.aws_security_group.redis: Refreshing state... [id=sg-03fb32147f4a39d81]
module.security.aws_security_group.rds: Refreshing state... [id=sg-08e10e08992448282]
module.networking.aws_route_table_association.private[0]: Refreshing state... [id=rtbassoc-0870e81cca8f64b3a]
module.networking.aws_route_table_association.private[1]: Refreshing state... [id=rtbassoc-0058343a764e57a54]
module.networking.aws_nat_gateway.this[0]: Refreshing state... [id=nat-09259ed9bf4742b99]
module.eks.aws_launch_template.nodes: Refreshing state... [id=lt-0ed887d0100c82665]
module.networking.aws_route.private_default_nat[0]: Refreshing state... [id=r-rtb-05ef29396bf3c0ad11080289494]
module.networking.aws_route.private_default_nat[1]: Refreshing state... [id=r-rtb-09b586bbcb4e2df4d1080289494]
module.eks.aws_eks_node_group.default: Refreshing state... [id=togglemaster-dev-eks:togglemaster-dev-default-ng]
module.elasticache.aws_elasticache_replication_group.redis: Refreshing state... [id=togglemaster-dev-redis]
module.rds.aws_db_instance.postgres["auth"]: Refreshing state... [id=db-VKB2Q2LO353WL5MG55VHNDF264]
module.rds.aws_db_instance.postgres["flags"]: Refreshing state... [id=db-I4LQAGAXOOP56BWHC2P7G574LE]
module.rds.aws_db_instance.postgres["targeting"]: Refreshing state... [id=db-Z44PRD2CXMSJF6UT4R2DPYPQGE]

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
/home/wellk/togglemaster-tc/fase4/tmp/bloco28/tfplan-capacity-fase4-apply.bin

To perform exactly these actions, run the following command to apply:
    terraform apply "/home/wellk/togglemaster-tc/fase4/tmp/bloco28/tfplan-capacity-fase4-apply.bin"

```

PLAN_RC: `2`

## 4. Revisão automática do plano pré-apply


### Revisão automática do plano

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

## 5. Terraform apply


### Terraform apply redigido

```text
module.eks.aws_eks_node_group.default: Modifying... [id=togglemaster-dev-eks:togglemaster-dev-default-ng]
module.eks.aws_eks_node_group.default: Modifications complete after 8s [id=togglemaster-dev-eks:togglemaster-dev-default-ng]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

alb_security_group_id = "sg-0bacf8e9e3cf22cf3"
application_secret_arns = <sensitive>
application_secret_names = {
  "analytics-service-config" = "togglemaster-dev/analytics-service-config"
  "auth-service-config" = "togglemaster-dev/auth-service-config"
  "evaluation-service-config" = "togglemaster-dev/evaluation-service-config"
  "flag-service-config" = "togglemaster-dev/flag-service-config"
  "targeting-service-config" = "togglemaster-dev/targeting-service-config"
}
aws_region = "us-east-1"
dynamodb_table_arn = "arn:aws:dynamodb:us-east-1:590183666984:table/togglemaster-dev-ToggleMasterAnalytics"
dynamodb_table_id = "togglemaster-dev-ToggleMasterAnalytics"
dynamodb_table_name = "togglemaster-dev-ToggleMasterAnalytics"
ecr_repository_arns = {
  "analytics-service" = "arn:aws:ecr:us-east-1:590183666984:repository/togglemaster-dev/analytics-service"
  "auth-service" = "arn:aws:ecr:us-east-1:590183666984:repository/togglemaster-dev/auth-service"
  "evaluation-service" = "arn:aws:ecr:us-east-1:590183666984:repository/togglemaster-dev/evaluation-service"
  "flag-service" = "arn:aws:ecr:us-east-1:590183666984:repository/togglemaster-dev/flag-service"
  "targeting-service" = "arn:aws:ecr:us-east-1:590183666984:repository/togglemaster-dev/targeting-service"
}
ecr_repository_names = {
  "analytics-service" = "togglemaster-dev/analytics-service"
  "auth-service" = "togglemaster-dev/auth-service"
  "evaluation-service" = "togglemaster-dev/evaluation-service"
  "flag-service" = "togglemaster-dev/flag-service"
  "targeting-service" = "togglemaster-dev/targeting-service"
}
ecr_repository_urls = {
  "analytics-service" = "590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service"
  "auth-service" = "590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service"
  "evaluation-service" = "590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service"
  "flag-service" = "590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service"
  "targeting-service" = "590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service"
}
eks_cluster_additional_security_group_id = "sg-0ec55ac590f25f604"
eks_cluster_endpoint = "https://47AAFA7006C0C5399AC8F2CE4704EEC7.gr7.us-east-1.eks.amazonaws.com"
eks_cluster_name = "togglemaster-dev-eks"
eks_lab_role_arn = "arn:aws:iam::590183666984:role/LabRole"
eks_node_group_name = "togglemaster-dev-default-ng"
eks_nodes_security_group_id = "sg-077f0782621a7b63f"
environment = "dev"
lab_role_name = "LabRole"
nat_eip_allocation_ids = [
  "eipalloc-083912e2b9aaf8647",
]
nat_gateway_ids = [
  "nat-09259ed9bf4742b99",
]
private_subnet_ids = [
  "subnet-05716f18fbd129998",
  "subnet-0f7f578133c62abd4",
]
project_name = "togglemaster"
public_subnet_ids = [
  "subnet-0b359eccd433dba23",
  "subnet-050e369beec248a7a",
]
rds_db_instance_addresses = {
  "auth" = "togglemaster-dev-auth-postgres.c1ucwe40y4w4.us-east-1.rds.amazonaws.com"
  "flags" = "togglemaster-dev-flags-postgres.c1ucwe40y4w4.us-east-1.rds.amazonaws.com"
  "targeting" = "togglemaster-dev-targeting-postgres.c1ucwe40y4w4.us-east-1.rds.amazonaws.com"
}
rds_db_instance_ports = {
  "auth" = 5432
  "flags" = 5432
  "targeting" = 5432
}
rds_db_names = {
  "auth" = "auth_db"
  "flags" = "flags_db"
  "targeting" = "targeting_db"
}
rds_master_user_secret_arns = <sensitive>
rds_security_group_id = "sg-08e10e08992448282"
redis_port = 6379
redis_primary_endpoint_address = "togglemaster-dev-redis.hmdfss.ng.0001.use1.cache.amazonaws.com"
redis_reader_endpoint_address = "togglemaster-dev-redis-ro.hmdfss.ng.0001.use1.cache.amazonaws.com"
redis_replication_group_id = "togglemaster-dev-redis"
redis_security_group_id = "sg-03fb32147f4a39d81"
sqs_queue_arn = "arn:aws:sqs:us-east-1:590183666984:togglemaster-dev-togglemaster-events"
sqs_queue_name = "togglemaster-dev-togglemaster-events"
sqs_queue_url = "https://sqs.us-east-1.amazonaws.com/590183666984/togglemaster-dev-togglemaster-events"
vpc_id = "vpc-06345e59392ca4c9f"

```

APPLY_RC: `0`

## 6. Aguardar node group ACTIVE


### Wait nodegroup active

- WAIT_NG_RC: `0`

### Nodegroup após apply

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
||  5            |  5        |  2        ||
|+---------------+-----------+-----------+|

```

RC: `0`

## 7. Aguardar 5 nodes Ready


### Nodes após aguardar escala

```text
NAME                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-40-95.ec2.internal    Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.40.95    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-45-215.ec2.internal   Ready    <none>   67s   v1.30.14-eks-7fcd7ec   10.10.45.215   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-48-118.ec2.internal   Ready    <none>   34s   v1.30.14-eks-7fcd7ec   10.10.48.118   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-49-137.ec2.internal   Ready    <none>   11h   v1.30.14-eks-7fcd7ec   10.10.49.137   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-50-171.ec2.internal   Ready    <none>   66s   v1.30.14-eks-7fcd7ec   10.10.50.171   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown

```

- TOTAL_NODES: `5`
- READY_NODES: `5`

## 8. Capacity check pós-apply


### Capacity check pós-apply

```text
Resumo por node:
- ip-10-10-40-95.ec2.internal
  allocatable.cpu=1930m
  allocatable.memory=1471796Ki
  pod.capacity=11
  pod.used=11
  pod.remaining=0
- ip-10-10-45-215.ec2.internal
  allocatable.cpu=1930m
  allocatable.memory=1471796Ki
  pod.capacity=11
  pod.used=2
  pod.remaining=9
- ip-10-10-48-118.ec2.internal
  allocatable.cpu=1930m
  allocatable.memory=1471792Ki
  pod.capacity=11
  pod.used=2
  pod.remaining=9
- ip-10-10-49-137.ec2.internal
  allocatable.cpu=1930m
  allocatable.memory=1471792Ki
  pod.capacity=11
  pod.used=11
  pod.remaining=0
- ip-10-10-50-171.ec2.internal
  allocatable.cpu=1930m
  allocatable.memory=1471796Ki
  pod.capacity=11
  pod.used=2
  pod.remaining=9

Resumo por namespace:
- argocd: 7 pods
- kube-system: 12 pods
- togglemaster: 9 pods

TOTAL_POD_CAPACITY=55
TOTAL_PODS_USED=28
TOTAL_PODS_REMAINING=27
REQUIRED_TOTAL_FREE_PODS=14
CAPACITY_GATE=PASS

```

## 9. Estado final


### Pods finais

```bash
$ kubectl get pods -A -o wide
NAMESPACE      NAME                                                READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
argocd         argocd-application-controller-0                     1/1     Running   0          11h   10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-applicationset-controller-5b964db9cd-rl8kn   1/1     Running   0          11h   10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-dex-server-b8cc6d795-r658p                   1/1     Running   0          11h   10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-notifications-controller-597cccd4ff-q2p2l    1/1     Running   0          11h   10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-redis-675f9c4c99-ngqb4                       1/1     Running   0          11h   10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd         argocd-repo-server-5c46694888-b4bqj                 1/1     Running   0          11h   10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd         argocd-server-7f66865588-df8sl                      1/1     Running   0          11h   10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system    aws-node-4tqtk                                      2/2     Running   0          11h   10.10.40.95    ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    aws-node-bfqsn                                      2/2     Running   0          69s   10.10.50.171   ip-10-10-50-171.ec2.internal   <none>           <none>
kube-system    aws-node-hxr94                                      2/2     Running   0          11h   10.10.49.137   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system    aws-node-jsf8t                                      2/2     Running   0          70s   10.10.45.215   ip-10-10-45-215.ec2.internal   <none>           <none>
kube-system    aws-node-w6wwq                                      2/2     Running   0          37s   10.10.48.118   ip-10-10-48-118.ec2.internal   <none>           <none>
kube-system    coredns-849f74687b-lg2g2                            1/1     Running   0          11h   10.10.45.165   ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    coredns-849f74687b-sqcpd                            1/1     Running   0          11h   10.10.41.233   ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    kube-proxy-4d2cb                                    1/1     Running   0          70s   10.10.45.215   ip-10-10-45-215.ec2.internal   <none>           <none>
kube-system    kube-proxy-57stg                                    1/1     Running   0          11h   10.10.40.95    ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    kube-proxy-chm7l                                    1/1     Running   0          69s   10.10.50.171   ip-10-10-50-171.ec2.internal   <none>           <none>
kube-system    kube-proxy-fm6l2                                    1/1     Running   0          11h   10.10.49.137   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system    kube-proxy-xth2f                                    1/1     Running   0          37s   10.10.48.118   ip-10-10-48-118.ec2.internal   <none>           <none>
togglemaster   analytics-service-6946467b6b-9fvmm                  1/1     Running   0          56m   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   auth-service-584688f79d-vpg2z                       1/1     Running   0          11h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   auth-service-584688f79d-xt6v8                       1/1     Running   0          11h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   evaluation-service-7949b95dd5-kf2md                 1/1     Running   0          56m   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   evaluation-service-7949b95dd5-wbrlc                 1/1     Running   0          55m   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   flag-service-7cd69f6bf9-9ffxm                       1/1     Running   0          11h   10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   flag-service-7cd69f6bf9-x7pxc                       1/1     Running   0          11h   10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   targeting-service-66d4bb78b6-7zc9d                  1/1     Running   0          11h   10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   targeting-service-66d4bb78b6-8tw7t                  1/1     Running   0          11h   10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>

```

RC: `0`

### ArgoCD application final

```bash
$ kubectl get application togglemaster-dev -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         d75514cb61b8809538b6eb24325f481f1ee21124   default

```

RC: `0`

### Git status final do script

```bash
$ git status --short
?? fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md
?? fase4/scripts/28_terraform_apply_eks_capacity.sh

```

RC: `0`

### Check tfstate/tfvars/plan versionados

```bash
$ bash -lc git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$|(^|/).*tfplan.*|(^|/).*\.bin$' || true

```

RC: `0`

## 10. Resultado


## Resultado

BLOCO 28 concluído com sucesso.

- `PLAN_RC=2`
- `PLAN_REVIEW=PASS_AUTOMATED_REVIEW`
- `APPLY_RC=0`
- `WAIT_NG_RC=0`
- `TOTAL_NODES=5`
- `READY_NODES=5`
- `CAPACITY_GATE=PASS`

Nenhuma stack de observabilidade foi instalada neste bloco.

Próximo passo recomendado:

1. versionar esta evidência;
2. iniciar preparação GitOps/Helm da stack base de observabilidade;
3. instalar Prometheus/Grafana/Loki/OTel em blocos controlados.

