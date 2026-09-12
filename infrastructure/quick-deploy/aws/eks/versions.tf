terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.64"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.0"
    }
  }
}
