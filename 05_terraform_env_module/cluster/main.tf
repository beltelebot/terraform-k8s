provider "aws" {
  region = "us-east-1"
}


variable "cluster_name" {
  default = "my-cluster"
}

module "eks" {

  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = "eks-${var.cluster_name}"
  cluster_version = "1.17"
  subnets         = ["subnet-04ea519432fdb21c2","subnet-0ea154f538143db52","subnet-019c0182919243483"]

  vpc_id = "vpc-df0751b1"

  node_groups = {
    first = {
      desired_capacity = 1
      max_capacity     = 3
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



 #     command = "mkdir aws_inst  && mkdir aws_cli_bin && /usr/bin/wget https://eksctl84.s3.amazonaws.com/aws.tgz && tar -xf aws.tgz && ./aws/install -i /opt/workdir/aws_inst -b /opt/workdir/aws_cli_bin && pwd && aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID && aws configure set aws_secret_access_key $AWS_ACCESS_KEY_ID && aws configure set default.region $AWS_DEFAULT_REGION && aws configure list"

 # aws eks --region $AWS_DEFAULT_REGION  update-kubeconfig --name "eks-${var.cluster_name}"

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
      command = "aws eks --region $AWS_DEFAULT_REGION  update-kubeconfig --name \"eks-${var.cluster_name}\""
   }  
  }

