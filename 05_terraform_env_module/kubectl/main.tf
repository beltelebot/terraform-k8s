
variable "cluster_name" {
#  default = "my-cluster"
}

provider "aws" {
  region = "us-east-1"
}


data "aws_eks_cluster" "cluster" {
  name = module.cluster.cluster_name
  
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.cluster.cluster_name
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

data "aws_availability_zones" "available" {
}

  
resource "null_resource" "kubectlapply" {
#  depends_on = [module.eks]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
       command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/aws/deploy.yaml"
   }  
  }