provider "aws" {
  region = var.region
}
##############################################


#data "aws_eks_cluster" "cluster" {
#  name = module.eks.cluster_id
#}

#data "aws_eks_cluster_auth" "cluster" {
#  name = module.eks.cluster_id
#}

#provider "kubernetes" {
#  host                   = data.aws_eks_cluster.cluster.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#  token                  = data.aws_eks_cluster_auth.cluster.token
#  load_config_file       = false
#  version                = "~> 1.11"
#}

#data "aws_availability_zones" "available" {
#}

#locals {
#  cluster_name = "stage"
#}

module "eks" {

  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version
  subnets         = var.cluster_subnet_ids

  vpc_id = var.vpc_id

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

  write_kubeconfig   = false
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
      command = "aws eks --region ${var.region}  update-kubeconfig --name ${var.cluster_name}"
   }  
  }



  resource "null_resource" "kubectl" {
  depends_on = [null_resource.awscli]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "/usr/bin/wget  https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl  -O /tmp/kubectl && chmod +x /tmp/kubectl"
     }  
  }


 
resource "null_resource" "kubectl_nginx_apply" {
  depends_on = [null_resource.kubectl]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
      command = "/tmp/kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/aws/deploy.yaml"
   }  
  }
