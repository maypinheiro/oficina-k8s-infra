terraform {
  required_version = ">= 1.5.6"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.6"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}
