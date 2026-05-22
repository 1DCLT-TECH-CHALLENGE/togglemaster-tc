variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnets privadas para o ElastiCache subnet group."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group do Redis."
  type        = string
}

variable "node_type" {
  description = "Tipo de node Redis. Deve ser validado conforme limites do AWS Academy."
  type        = string
  default     = "cache.t3.micro"
}

variable "engine_version" {
  description = "Versão do Redis."
  type        = string
  default     = "7.0"
}

variable "port" {
  description = "Porta Redis."
  type        = number
  default     = 6379
}

variable "automatic_failover_enabled" {
  description = "Habilita failover automático. Em dev/Academy começa falso para reduzir complexidade/custo."
  type        = bool
  default     = false
}

variable "num_cache_clusters" {
  description = "Quantidade de nodes do replication group."
  type        = number
  default     = 1
}

variable "at_rest_encryption_enabled" {
  description = "Habilita criptografia em repouso."
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Habilita criptografia em trânsito. Inicialmente falso para evitar necessidade de auth_token no Academy."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
