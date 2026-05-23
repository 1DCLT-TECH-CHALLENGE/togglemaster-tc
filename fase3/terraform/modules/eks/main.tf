locals {
  common_tags = merge(
    var.tags,
    {
      Module = "eks"
    }
  )
}

data "aws_iam_role" "lab_role" {
  name = var.lab_role_name
}

resource "aws_eks_cluster" "this" {

  timeouts {
    create = "75m"
    update = "75m"
    delete = "60m"
  }

  name     = "${var.name_prefix}-eks"
  role_arn = data.aws_iam_role.lab_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [var.cluster_additional_security_group_id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-eks"
    }
  )
}

resource "aws_launch_template" "nodes" {
  name_prefix = "${var.name_prefix}-eks-nodes-"

  vpc_security_group_ids = [
    var.node_security_group_id,
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.name_prefix}-eks-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.name_prefix}-eks-node-volume"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-eks-nodes-lt"
    }
  )
}

resource "aws_eks_node_group" "default" {

  timeouts {
    create = "75m"
    update = "75m"
    delete = "60m"
  }

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name_prefix}-default-ng"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types
  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = "$Latest"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-default-ng"
    }
  )

  depends_on = [
    aws_eks_cluster.this,
    aws_launch_template.nodes
  ]
}
