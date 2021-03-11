provider "aws" {
  region = "us-east-1"
}


variable "cluster_name" {
  default = "my-cluster"
}

module "eks" {

  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = "${local.cluster_name}"
  cluster_version = "1.17"
  subnets         = ["subnet-04ea519432fdb21c2","subnet-0ea154f538143db52","subnet-019c0182919243483"]

  vpc_id = "vpc-df0751b1"

  node_groups = {
    first = {
      desired_capacity = 1
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "m5.large"
    }
 #   second = {
 #     desired_capacity = 1
 #     max_capacity     = 3
 #     min_capacity     = 1

 #     instance_type = "t2.micro"
 #   }
  }

  write_kubeconfig   = true
  config_output_path = "./"
}