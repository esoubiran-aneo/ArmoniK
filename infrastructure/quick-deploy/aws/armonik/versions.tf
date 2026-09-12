terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.4.1"
    }
  }
}