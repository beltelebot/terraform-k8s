terraform {
  required_version = ">= 0.14.3"
  required_providers {
    helm = {
      version = "=1.3.2"
    }
    null = {
      version = ">=3.0.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}


