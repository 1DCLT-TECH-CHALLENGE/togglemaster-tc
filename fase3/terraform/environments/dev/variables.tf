variable "project_name" {
  description = "Nome base do projeto."
  type        = string
  default     = "togglemaster"
}

variable "environment" {
  description = "Ambiente alvo."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região AWS usada no AWS Academy Lab."
  type        = string
  default     = "us-east-1"
}

variable "lab_role_name" {
  description = "Nome da IAM Role existente no AWS Academy. Não criar role nova."
  type        = string
  default     = "LabRole"
}

variable "vpc_cidr" {
  description = "CIDR da VPC da Fase 3."
  type        = string
  default     = "10.30.0.0/16"
}

variable "availability_zones" {
  description = "AZs do ambiente dev. Ajustar somente após abrir o AWS Academy, se necessário."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "service_names" {
  description = "Microsserviços ToggleMaster que terão imagem no ECR e manifests Kubernetes."
  type        = list(string)
  default = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service"
  ]
}

variable "tags" {
  description = "Tags padrão dos recursos."
  type        = map(string)
  default = {
    Project     = "ToggleMaster"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Course      = "FIAP-Tech-Challenge"
  }
}
