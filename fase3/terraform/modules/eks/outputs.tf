output "cluster_name" {
  description = "Nome do cluster EKS."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN do cluster EKS."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA data do cluster EKS."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "node_group_name" {
  description = "Nome do managed node group."
  value       = aws_eks_node_group.default.node_group_name
}

output "lab_role_arn" {
  description = "ARN da LabRole usada pelo cluster e node group."
  value       = data.aws_iam_role.lab_role.arn
}
