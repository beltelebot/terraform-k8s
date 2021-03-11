provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
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

locals {
  cluster_name = "stage"
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

#  write_kubeconfig   = false
#  config_output_path = "./"
}

resource "null_resource" "awscli" {
  depends_on = [module.eks]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
      command = "mkdir aws_inst  && mkdir aws_cli_bin && /usr/bin/wget https://eksctl84.s3.amazonaws.com/aws.tgz && tar -xf aws.tgz && ./aws/install -i /opt/workdir/aws_inst -b /opt/workdir/aws_cli_bin && pwd && aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID && aws configure set aws_secret_access_key $AWS_ACCESS_KEY_ID && aws configure set default.region $AWS_DEFAULT_REGION && aws configure list"
   }  
  }


resource "null_resource" "kubectl_connect" {
  depends_on = [null_resource.awscli]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
      command = "aws eks --region $AWS_DEFAULT_REGION  update-kubeconfig --name local.cluster_name"
   }  
  }



  resource "null_resource" "kubectl_connect" {
  depends_on = [null_resource.awscli]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<-EOT
       exec "/usr/bin/curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl"
    EOT
   }  
  }


 
resource "null_resource" "kubectl_nginx_apply" {
  depends_on = [null_resource.kubectl_connect]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
      command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/aws/deploy.yaml"
   }  
  }
