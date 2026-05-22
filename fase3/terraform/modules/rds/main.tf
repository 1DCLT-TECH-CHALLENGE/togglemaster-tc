locals {
  common_tags = merge(
    var.tags,
    {
      Module = "rds"
    }
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-rds-subnet-group"
    }
  )
}

resource "aws_db_instance" "postgres" {
  for_each = var.database_names

  identifier = "${var.name_prefix}-${each.key}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true

  db_name  = each.value.db_name
  username = each.value.username

  # Não definir password em código, tfvars ou env.
  # O RDS gerencia o segredo no AWS Secrets Manager.
  # Validar permissão no AWS Academy antes do primeiro plan/apply.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.name_prefix}-${each.key}-postgres"
      Service = each.key
    }
  )
}
