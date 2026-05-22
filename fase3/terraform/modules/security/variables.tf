variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR da VPC."
  type        = string
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
