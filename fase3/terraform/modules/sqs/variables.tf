variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "queue_name" {
  description = "Nome lógico da fila SQS."
  type        = string
  default     = "togglemaster-events"
}

variable "message_retention_seconds" {
  description = "Tempo de retenção das mensagens em segundos."
  type        = number
  default     = 345600
}

variable "visibility_timeout_seconds" {
  description = "Timeout de visibilidade das mensagens em segundos."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
