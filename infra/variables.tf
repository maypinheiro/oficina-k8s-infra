variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["hml", "prod"], var.environment)
    error_message = "environment deve ser hml ou prod."
  }
}

variable "cluster_name" {
  type    = string
  default = null
}

variable "cluster_role_arn" {
  description = "Role de servico permitida pelo Learner Lab para o control plane EKS."
  type        = string
}

variable "node_role_arn" {
  description = "Role permitida pelo Learner Lab para os managed nodes."
  type        = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "enable_nat_gateway" {
  description = "NAT unico para nodes privados; desligar somente com VPC endpoints equivalentes."
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  type    = string
  default = "1.33"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "cluster_public_access_cidrs" {
  description = "CIDRs administrativos autorizados no endpoint publico do EKS."
  type        = list(string)

  validation {
    condition     = length(var.cluster_public_access_cidrs) > 0 && !contains(var.cluster_public_access_cidrs, "0.0.0.0/0")
    error_message = "Informe ao menos um CIDR administrativo restrito; 0.0.0.0/0 nao e permitido."
  }
}

variable "datadog_api_key" {
  type      = string
  sensitive = true
}

variable "datadog_app_key" {
  type      = string
  sensitive = true
}

variable "datadog_api_url" {
  type    = string
  default = "https://api.datadoghq.com/"
}
variable "alert_notification" {
  description = "Handle Datadog, por exemplo @email ou @slack-canal."
  type        = string
  default     = ""
}

variable "enable_log_monitors" {
  description = "Habilita monitores de logs depois que Log Management estiver ativo na organizacao Datadog."
  type        = bool
  default     = false
}
