output "replication_group_id" {
  description = "ID do replication group Redis."
  value       = aws_elasticache_replication_group.redis.id
}

output "primary_endpoint_address" {
  description = "Endpoint primário do Redis."
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Endpoint de leitura do Redis, quando disponível."
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "port" {
  description = "Porta Redis."
  value       = aws_elasticache_replication_group.redis.port
}
