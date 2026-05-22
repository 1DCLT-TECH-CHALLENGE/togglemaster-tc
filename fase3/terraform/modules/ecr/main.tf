locals {
  common_tags = merge(
    var.tags,
    {
      Module = "ecr"
    }
  )

  repositories = toset(var.service_names)
}

resource "aws_ecr_repository" "this" {
  for_each = local.repositories

  name                 = "${var.name_prefix}/${each.key}"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.name_prefix}-${each.key}"
      Service = each.key
    }
  )
}

resource "aws_ecr_lifecycle_policy" "keep_last_images" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manter apenas as ultimas 10 imagens"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
