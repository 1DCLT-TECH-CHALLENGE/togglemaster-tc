# Fase 4 - BLOCO 26 - Alteração IaC de Capacidade do EKS

Data: Sat May 23 03:01:28 PM -03 2026

## Objetivo

Alterar o Terraform do ambiente dev para ampliar a capacidade do EKS antes da instalação da stack de observabilidade da Fase 4.

Este bloco:

- altera código IaC versionado;
- executa `terraform fmt`;
- executa `terraform init -backend=false`;
- executa `terraform validate`;
- não executa `terraform plan`;
- não executa `terraform apply`;
- não altera recursos AWS nesta etapa.


## 1. Estado Git inicial


### Git status

```bash
$ git status --short
?? fase4/docs/evidencias/fase4-bloco26-iac-capacidade-eks.md
?? fase4/scripts/26_patch_terraform_eks_capacity.sh

```

RC: `0`

### Últimos commits

```bash
$ git log --oneline --decorate -8
72bb291 (HEAD -> main, origin/main) docs: plan phase 4 observability capacity fix
7d6f15d docs: record phase 4 observability capacity gate
4680d8b docs: record phase 4 stack inventory
74f1c33 docs: open phase 4 delivery
0d26f9f docs: add pre phase 4 readiness gate
e38cf8d fix: prevent phase 2 e2e from persisting runtime api key
d7666dd docs: record phase 2 local pre phase 4 revalidation
eab9b9d docs: record phase 3 pre phase 4 app validation

```

RC: `0`
- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 26.

## 2. Pré-checks Terraform


### Terraform version

```bash
$ terraform version
Terraform v1.15.3
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.15.4. You can update by downloading from https://developer.hashicorp.com/terraform/install

```

RC: `0`

### Arquivos Terraform relevantes

```bash
$ bash -lc find fase3/terraform/modules/eks fase3/terraform/environments/dev -maxdepth 2 -type f \( -name '*.tf' -o -name '*.tfvars.example' \) | sort
fase3/terraform/environments/dev/main.tf
fase3/terraform/environments/dev/outputs.tf
fase3/terraform/environments/dev/providers.tf
fase3/terraform/environments/dev/terraform.tfvars.example
fase3/terraform/environments/dev/variables.tf
fase3/terraform/environments/dev/versions.tf
fase3/terraform/modules/eks/main.tf
fase3/terraform/modules/eks/outputs.tf
fase3/terraform/modules/eks/variables.tf

```

RC: `0`

### Check tfstate/tfvars versionados

```bash
$ bash -lc git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true

```

RC: `0`
- OK: nenhum tfstate/tfvars real está versionado.

## 3. Backup local e patch seguro do main.tf


### Diff do main.tf

```diff
diff --git a/fase3/terraform/environments/dev/main.tf b/fase3/terraform/environments/dev/main.tf
index aa8a55d..8dc634b 100644
--- a/fase3/terraform/environments/dev/main.tf
+++ b/fase3/terraform/environments/dev/main.tf
@@ -81,6 +81,10 @@ module "eks" {
   cluster_additional_security_group_id = module.security.eks_cluster_additional_security_group_id
   node_security_group_id               = module.security.eks_nodes_security_group_id
   tags                                 = var.tags
+  node_instance_types = ["t3.small"]
+  node_min_size = 2
+  node_desired_size = 5
+  node_max_size = 5
 }
 
 

```

## 4. Terraform fmt/init/validate


### Terraform fmt recursive

```bash
$ terraform -chdir=fase3/terraform fmt -recursive
environments/dev/main.tf

```

RC: `0`

### Terraform init backend false

```bash
$ terraform -chdir=fase3/terraform/environments/dev init -backend=false
[0m[1mInitializing modules...[0m
[0m[1mInitializing provider plugins found in the configuration...[0m
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/kubernetes from the dependency lock file
- Reusing previous version of hashicorp/helm from the dependency lock file
- Using previously-installed hashicorp/aws v6.46.0
- Using previously-installed hashicorp/random v3.9.0
- Using previously-installed hashicorp/kubernetes v3.1.0
- Using previously-installed hashicorp/helm v3.1.2


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

## 5. Conferência pós-patch


### Valores EKS no main.tf

```bash
$ bash -lc grep -nE 'module "eks"|node_instance_types|node_min_size|node_desired_size|node_max_size' fase3/terraform/environments/dev/main.tf
75:module "eks" {
84:  node_instance_types                  = ["t3.small"]
85:  node_min_size                        = 2
86:  node_desired_size                    = 5
87:  node_max_size                        = 5

```

RC: `0`

### Git diff stat

```bash
$ git diff --stat
 fase3/terraform/environments/dev/main.tf | 4 ++++
 1 file changed, 4 insertions(+)

```

RC: `0`

### Git diff Terraform

```bash
$ git diff -- fase3/terraform/environments/dev/main.tf fase3/terraform/modules/eks
diff --git a/fase3/terraform/environments/dev/main.tf b/fase3/terraform/environments/dev/main.tf
index aa8a55d..52ea975 100644
--- a/fase3/terraform/environments/dev/main.tf
+++ b/fase3/terraform/environments/dev/main.tf
@@ -81,6 +81,10 @@ module "eks" {
   cluster_additional_security_group_id = module.security.eks_cluster_additional_security_group_id
   node_security_group_id               = module.security.eks_nodes_security_group_id
   tags                                 = var.tags
+  node_instance_types                  = ["t3.small"]
+  node_min_size                        = 2
+  node_desired_size                    = 5
+  node_max_size                        = 5
 }
 
 

```

RC: `0`

## 6. Segurança


### Check final tfstate/tfvars versionados

```bash
$ bash -lc git ls-files | grep -E '(^|/).*\.tfstate(\.backup)?$|(^|/)terraform\.tfvars$|\.auto\.tfvars$' || true

```

RC: `0`

## Segurança

Nenhum arquivo `tfstate`, `terraform.tfvars` real ou `*.auto.tfvars` foi versionado neste bloco.


## 7. Resultado


## Resultado

BLOCO 26 concluído com sucesso.

A alteração IaC foi preparada e validada localmente.

Próximo bloco recomendado:

1. gerar `terraform plan` em bloco separado;
2. revisar se o plano altera somente o necessário no EKS node group;
3. executar `terraform apply` somente após revisão.

