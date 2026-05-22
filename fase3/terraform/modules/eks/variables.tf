variable "name_prefix" {
  description = "Prefixo de nome dos recursos."
  type        = string
}

variable "lab_role_name" {
  description = "Nome da IAM Role existente no AWS Academy. Não criar role nova."
  type        = string
  default     = "LabRole"
}

variable "private_subnet_ids" {
  description = "Subnets privadas para EKS e node groups."
  type        = list(string)
}

variable "cluster_additional_security_group_id" {
  description = "Security Group adicional do EKS control plane."
  type        = string
}

variable "node_security_group_id" {
  description = "Security Group dos nodes EKS."
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes no EKS."
  type        = string
  default     = "1.30"
}

variable "endpoint_private_access" {
  description = "Habilita endpoint privado do cluster."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Habilita endpoint público do cluster."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "Tipos de instância do managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_desired_size" {
  description = "Quantidade desejada de nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Quantidade mínima de nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Quantidade máxima de nodes."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Disco dos nodes em GB."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default     = {}
}
