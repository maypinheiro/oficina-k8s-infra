terraform {
  required_version = ">= 1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
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
