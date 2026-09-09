variable "cluster_name" {
  description = "Nome do cluster Kubernetes local."
  type        = string
  default     = "oficina-local"

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "O nome do cluster nao pode ser vazio."
  }
}

variable "namespace" {
  description = "Namespace criado para a aplicacao."
  type        = string
  default     = "oficina"

  validation {
    condition     = length(trimspace(var.namespace)) > 0
    error_message = "O namespace nao pode ser vazio."
  }
}

variable "deploy_app" {
  description = "Controla a aplicacao dos manifestos da API e HPA."
  type        = bool
  default     = true
}
