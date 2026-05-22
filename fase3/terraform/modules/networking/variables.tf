variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC."
  type        = string
}

variable "availability_zones" {
  description = "Lista de AZs usadas para criar subnets."
  type        = list(string)
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
