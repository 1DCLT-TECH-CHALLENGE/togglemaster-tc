locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "networking" {
  source = "../../modules/networking"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = var.tags
}


module "security" {
  source = "../../modules/security"

  name_prefix    = local.name_prefix
  vpc_id         = module.networking.vpc_id
  vpc_cidr_block = module.networking.vpc_cidr_block
  tags           = var.tags
}


module "ecr" {
  source = "../../modules/ecr"

  name_prefix   = local.name_prefix
  service_names = var.service_names
  tags          = var.tags
}


module "sqs" {
  source = "../../modules/sqs"

  name_prefix = local.name_prefix
  tags        = var.tags
}


module "dynamodb" {
  source = "../../modules/dynamodb"

  name_prefix = local.name_prefix
  tags        = var.tags
}


module "rds" {
  source = "../../modules/rds"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id  = module.security.rds_security_group_id
  tags               = var.tags
}


module "elasticache" {
  source = "../../modules/elasticache"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id  = module.security.redis_security_group_id
  tags               = var.tags
}


module "eks" {
  source = "../../modules/eks"

  name_prefix                          = local.name_prefix
  lab_role_name                        = var.lab_role_name
  private_subnet_ids                   = module.networking.private_subnet_ids
  cluster_additional_security_group_id = module.security.eks_cluster_additional_security_group_id
  node_security_group_id               = module.security.eks_nodes_security_group_id
  tags                                 = var.tags
}


module "secrets" {
  source = "../../modules/secrets"

  name_prefix = local.name_prefix
  tags        = var.tags
}

# Próximos módulos serão conectados em blocos separados:
# - argocd
