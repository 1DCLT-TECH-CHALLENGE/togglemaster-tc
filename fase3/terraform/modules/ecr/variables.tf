variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "service_names" {
  description = "Lista de serviços que terão repositório ECR."
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "Mutabilidade das tags das imagens."
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability deve ser MUTABLE ou IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Habilita scan de imagem no push."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Permite deletar repositórios ECR com imagens durante destroy em ambiente dev."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
