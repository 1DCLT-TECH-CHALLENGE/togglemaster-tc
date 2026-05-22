output "secret_arns" {
  description = "ARNs dos secrets por nome lógico."
  value       = { for name, secret in aws_secretsmanager_secret.this : name => secret.arn }
}

output "secret_names" {
  description = "Nomes dos secrets por nome lógico."
  value       = { for name, secret in aws_secretsmanager_secret.this : name => secret.name }
}
