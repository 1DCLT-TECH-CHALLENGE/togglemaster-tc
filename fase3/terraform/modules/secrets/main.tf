locals {
  common_tags = merge(
    var.tags,
    {
      Module = "secrets"
    }
  )
}

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secret_names

  name                    = "${var.name_prefix}/${each.key}"
  description             = "Secret metadata para ${each.key}. Valor real não é definido pelo Terraform neste módulo."
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.name_prefix}/${each.key}"
      Purpose = "application-runtime-configuration"
    }
  )
}
