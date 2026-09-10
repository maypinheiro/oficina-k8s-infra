terraform {
  required_version = ">= 1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.50"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "techchallenge-oficina"
      Environment = var.environment
      ManagedBy   = "terraform"
      CostCenter  = "fiap-fase3"
      Repository  = "oficina-k8s-infra"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}
