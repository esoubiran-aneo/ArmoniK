terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.2"
    }
  }
}