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


variable "subnet_newbits" {
  description = "Quantidade de bits adicionais para cálculo das subnets. Com VPC /16 e valor 4, gera subnets /20."
  type        = number
  default     = 4
}

variable "public_subnet_offset" {
  description = "Offset inicial das subnets públicas dentro do CIDR da VPC."
  type        = number
  default     = 0
}

variable "private_subnet_offset" {
  description = "Offset inicial das subnets privadas dentro do CIDR da VPC."
  type        = number
  default     = 2
}


variable "enable_nat_gateway" {
  description = "Habilita NAT Gateway para saída das subnets privadas."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Quando true, usa um único NAT Gateway para reduzir custo/complexidade em dev/AWS Academy."
  type        = bool
  default     = true
}
