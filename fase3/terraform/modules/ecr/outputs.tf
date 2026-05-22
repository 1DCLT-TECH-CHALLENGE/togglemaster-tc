output "repository_names" {
  description = "Nomes dos repositórios ECR."
  value       = { for service, repo in aws_ecr_repository.this : service => repo.name }
}

output "repository_urls" {
  description = "URLs dos repositórios ECR."
  value       = { for service, repo in aws_ecr_repository.this : service => repo.repository_url }
}

output "repository_arns" {
  description = "ARNs dos repositórios ECR."
  value       = { for service, repo in aws_ecr_repository.this : service => repo.arn }
}
