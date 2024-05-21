terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2"
    }
  }
}
