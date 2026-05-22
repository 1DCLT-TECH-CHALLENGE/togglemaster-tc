variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "secret_names" {
  description = "Nomes logicos dos secrets a serem criados sem valores."
  type        = set(string)
  default = [
    "auth-service-config",
    "flag-service-config",
    "targeting-service-config",
    "evaluation-service-config",
    "analytics-service-config"
  ]
}

variable "recovery_window_in_days" {
  description = "Janela de recuperação dos secrets. Em dev/Academy começa curta para facilitar limpeza."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
