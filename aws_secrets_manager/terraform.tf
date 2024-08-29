terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
  }
}
