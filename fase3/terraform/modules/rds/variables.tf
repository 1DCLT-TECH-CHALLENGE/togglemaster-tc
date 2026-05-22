variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnets privadas para o DB subnet group."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group do RDS."
  type        = string
}

variable "database_names" {
  description = "Bancos PostgreSQL a serem criados para os serviços."
  type = map(object({
    db_name  = string
    username = string
  }))

  default = {
    auth = {
      db_name  = "auth_db"
      username = "auth_user"
    }
    flags = {
      db_name  = "flags_db"
      username = "flags_user"
    }
    targeting = {
      db_name  = "targeting_db"
      username = "targeting_user"
    }
  }
}

variable "engine_version" {
  description = "Versão do PostgreSQL."
  type        = string
  default     = "15"
}

variable "instance_class" {
  description = "Classe das instâncias RDS. Deve ser ajustada conforme limites do AWS Academy."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage inicial em GB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Storage máximo em GB para autoscaling de storage."
  type        = number
  default     = 50
}

variable "backup_retention_period" {
  description = "Retenção de backup em dias."
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "Proteção contra deleção. Em dev/Academy começa falso para facilitar limpeza do lab."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Ignora snapshot final em destroy. Em dev/Academy começa true para facilitar limpeza do lab."
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "RDS deve ficar privado."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
