locals {
  common_tags = merge(
    var.tags,
    {
      Module = "dynamodb"
    }
  )
}

resource "aws_dynamodb_table" "analytics" {
  name         = "${var.name_prefix}-${var.table_name}"
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  ttl {
    enabled        = var.ttl_enabled
    attribute_name = var.ttl_attribute_name
  }

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.name_prefix}-${var.table_name}"
      Purpose = "feature-flag-analytics-events"
    }
  )
}
