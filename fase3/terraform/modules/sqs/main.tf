locals {
  common_tags = merge(
    var.tags,
    {
      Module = "sqs"
    }
  )
}

resource "aws_sqs_queue" "events" {
  name = "${var.name_prefix}-${var.queue_name}"

  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  sqs_managed_sse_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.name_prefix}-${var.queue_name}"
      Purpose = "feature-flag-evaluation-events"
    }
  )
}
