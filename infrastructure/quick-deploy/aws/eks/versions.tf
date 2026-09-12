terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.4.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9.1"
    }
  }
}
