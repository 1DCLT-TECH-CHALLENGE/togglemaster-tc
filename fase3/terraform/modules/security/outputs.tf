output "alb_security_group_id" {
  description = "Security Group do ALB."
  value       = aws_security_group.alb.id
}

output "eks_cluster_additional_security_group_id" {
  description = "Security Group adicional do EKS control plane."
  value       = aws_security_group.eks_cluster_additional.id
}

output "eks_nodes_security_group_id" {
  description = "Security Group dos EKS nodes."
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "Security Group dos RDS PostgreSQL."
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "Security Group do Redis."
  value       = aws_security_group.redis.id
}
