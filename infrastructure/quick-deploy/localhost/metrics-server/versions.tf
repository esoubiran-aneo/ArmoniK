terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.4.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.4.1"
    }
  }
}
