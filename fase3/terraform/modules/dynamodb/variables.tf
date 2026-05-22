variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "table_name" {
  description = "Nome lógico da tabela DynamoDB."
  type        = string
  default     = "ToggleMasterAnalytics"
}

variable "hash_key" {
  description = "Chave primária HASH da tabela."
  type        = string
  default     = "event_id"
}

variable "billing_mode" {
  description = "Modo de cobrança da tabela."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode deve ser PAY_PER_REQUEST ou PROVISIONED."
  }
}

variable "point_in_time_recovery_enabled" {
  description = "Habilita Point-in-Time Recovery."
  type        = bool
  default     = false
}

variable "ttl_enabled" {
  description = "Habilita TTL para expiração automática de eventos."
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Nome do atributo TTL."
  type        = string
  default     = "ttl"
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
