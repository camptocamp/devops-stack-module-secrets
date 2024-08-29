terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2"
    }
  }
}
