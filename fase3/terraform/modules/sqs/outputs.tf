output "queue_name" {
  description = "Nome da fila SQS."
  value       = aws_sqs_queue.events.name
}

output "queue_url" {
  description = "URL da fila SQS."
  value       = aws_sqs_queue.events.url
}

output "queue_arn" {
  description = "ARN da fila SQS."
  value       = aws_sqs_queue.events.arn
}
