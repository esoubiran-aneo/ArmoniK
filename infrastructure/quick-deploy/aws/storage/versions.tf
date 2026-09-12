terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.4.1"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "~> 0.4.0"
    }
  }
}
