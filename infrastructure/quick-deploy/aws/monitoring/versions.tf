terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }
  }
}
