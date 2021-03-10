provider "aws" {
  region = "us-east-1"
}


provider "http" {}


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
}

data "aws_availability_zones" "available" {
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
#  version = "12.2.0"

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
  workers_additional_policies = [aws_iam_policy.worker_policy.arn]
}

resource "aws_iam_policy" "worker_policy" {
 
  name        = "worker-policy-${var.cluster_name}"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

  
resource "null_resource" "kubectl" {
  depends_on = [module.eks]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
       command = "/usr/bin/wget https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl && chmod +x kubectl"
   }  
  }
  
  resource "null_resource" "authenticator" {
  depends_on = [null_resource.kubectl]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
       command = "  /usr/bin/curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator && chmod +x aws-iam-authenticator && mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin"
   }  
  }

  
 provider "helm" {
  kubernetes {
    config_path = "./kubeconfig_eks-staging"
  }
}

resource "helm_release" "nginx_ingress" {
  depends_on = [null_resource.authenticator]   
  name       = "nginx-ingress-controller"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}   

