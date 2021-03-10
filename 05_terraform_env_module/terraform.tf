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



provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

  
 provider "helm" {
  kubernetes {
    config_path = "./kubeconfig_eks-staging"
  }
}

