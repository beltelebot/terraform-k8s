terraform {
  required_providers {
    aws = {
     source  = "hashicorp/aws"
     version = "~> 3.31.0"
    }
  }
  required_version = ">= 0.14"
}


provider "aws" {
  region = "us-east-1"
}


provider "http" {}



  
 provider "helm" {
  kubernetes {
    config_path = "./kubeconfig_eks-staging"
  }
}

