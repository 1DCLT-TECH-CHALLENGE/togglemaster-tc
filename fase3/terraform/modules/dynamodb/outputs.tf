output "table_name" {
  description = "Nome da tabela DynamoDB."
  value       = aws_dynamodb_table.analytics.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB."
  value       = aws_dynamodb_table.analytics.arn
}

output "table_id" {
  description = "ID da tabela DynamoDB."
  value       = aws_dynamodb_table.analytics.id
}
