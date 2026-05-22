output "db_instance_ids" {
  description = "IDs das instâncias RDS por banco lógico."
  value       = { for name, db in aws_db_instance.postgres : name => db.id }
}

output "db_instance_addresses" {
  description = "Endpoints/address das instâncias RDS por banco lógico."
  value       = { for name, db in aws_db_instance.postgres : name => db.address }
}

output "db_instance_ports" {
  description = "Portas das instâncias RDS por banco lógico."
  value       = { for name, db in aws_db_instance.postgres : name => db.port }
}

output "db_names" {
  description = "Nomes dos bancos criados."
  value       = { for name, db in aws_db_instance.postgres : name => db.db_name }
}

output "master_user_secret_arns" {
  description = "ARNs dos secrets gerenciados pelo RDS no Secrets Manager."
  value       = { for name, db in aws_db_instance.postgres : name => db.master_user_secret[0].secret_arn }
  sensitive   = true
}
