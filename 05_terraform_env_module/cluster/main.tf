provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

variable "cluster_name" {
  default = "my-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "12.2.0"

  cluster_name    = "eks-${var.cluster_name}"
  cluster_version = "1.19"
  subnets         =  ["subnet-04ea519432fdb21c2","subnet-0ea154f538143db52","subnet-019c0182919243483"]

  vpc_id =  "vpc-df0751b1"

  node_groups = {
    first = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "m5.large"
    }
  }

  write_kubeconfig   = true
  config_output_path = "./"

  workers_additional_policies = [aws_iam_policy.worker_policy.arn]
}

resource "aws_iam_policy" "worker_policy" {
 
  name        = "worker-policy-${var.cluster_name}"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

  provider "helm" {
  version = "1.3.1"
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

resource "helm_release" "ingress" {
  depends_on = [module.eks]    
  name       = "ingress"
  chart      = "aws-alb-ingress-controller"
  repository = "https://charts.helm.sh/incubator"
  version    = "1.0.2"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}
