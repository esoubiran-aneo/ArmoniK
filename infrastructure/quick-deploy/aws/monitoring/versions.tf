terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.21.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}
