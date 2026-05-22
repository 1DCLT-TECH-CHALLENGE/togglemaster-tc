output "project_name" {
  description = "Nome do projeto."
  value       = var.project_name
}

output "environment" {
  description = "Ambiente Terraform."
  value       = var.environment
}

output "aws_region" {
  description = "Região configurada."
  value       = var.aws_region
}

output "lab_role_name" {
  description = "IAM Role esperada no AWS Academy."
  value       = var.lab_role_name
}

output "vpc_id" {
  description = "ID da VPC criada pelo módulo networking."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Subnets públicas."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Subnets privadas."
  value       = module.networking.private_subnet_ids
}

output "alb_security_group_id" {
  description = "Security Group do ALB."
  value       = module.security.alb_security_group_id
}

output "eks_cluster_additional_security_group_id" {
  description = "Security Group adicional do EKS control plane."
  value       = module.security.eks_cluster_additional_security_group_id
}

output "eks_nodes_security_group_id" {
  description = "Security Group dos EKS nodes."
  value       = module.security.eks_nodes_security_group_id
}

output "rds_security_group_id" {
  description = "Security Group dos bancos RDS PostgreSQL."
  value       = module.security.rds_security_group_id
}

output "redis_security_group_id" {
  description = "Security Group do ElastiCache Redis."
  value       = module.security.redis_security_group_id
}

output "ecr_repository_names" {
  description = "Nomes dos repositórios ECR por serviço."
  value       = module.ecr.repository_names
}

output "ecr_repository_urls" {
  description = "URLs dos repositórios ECR por serviço."
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ARNs dos repositórios ECR por serviço."
  value       = module.ecr.repository_arns
}

output "sqs_queue_name" {
  description = "Nome da fila SQS de eventos."
  value       = module.sqs.queue_name
}

output "sqs_queue_url" {
  description = "URL da fila SQS de eventos."
  value       = module.sqs.queue_url
}

output "sqs_queue_arn" {
  description = "ARN da fila SQS de eventos."
  value       = module.sqs.queue_arn
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB de analytics."
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB de analytics."
  value       = module.dynamodb.table_arn
}

output "dynamodb_table_id" {
  description = "ID da tabela DynamoDB de analytics."
  value       = module.dynamodb.table_id
}

output "rds_db_instance_addresses" {
  description = "Endpoints RDS por banco lógico."
  value       = module.rds.db_instance_addresses
}

output "rds_db_instance_ports" {
  description = "Portas RDS por banco lógico."
  value       = module.rds.db_instance_ports
}

output "rds_db_names" {
  description = "Nomes dos bancos RDS."
  value       = module.rds.db_names
}

output "rds_master_user_secret_arns" {
  description = "ARNs dos secrets gerenciados pelo RDS no Secrets Manager."
  value       = module.rds.master_user_secret_arns
  sensitive   = true
}

output "redis_replication_group_id" {
  description = "ID do replication group Redis."
  value       = module.elasticache.replication_group_id
}

output "redis_primary_endpoint_address" {
  description = "Endpoint primário do Redis."
  value       = module.elasticache.primary_endpoint_address
}

output "redis_reader_endpoint_address" {
  description = "Endpoint de leitura do Redis."
  value       = module.elasticache.reader_endpoint_address
}

output "redis_port" {
  description = "Porta Redis."
  value       = module.elasticache.port
}

output "eks_cluster_name" {
  description = "Nome do cluster EKS."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS."
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Nome do managed node group."
  value       = module.eks.node_group_name
}

output "eks_lab_role_arn" {
  description = "ARN da LabRole usada pelo EKS."
  value       = module.eks.lab_role_arn
}

output "application_secret_arns" {
  description = "ARNs dos Secrets Manager para configuração das aplicações."
  value       = module.secrets.secret_arns
  sensitive   = true
}

output "application_secret_names" {
  description = "Nomes dos Secrets Manager para configuração das aplicações."
  value       = module.secrets.secret_names
}
