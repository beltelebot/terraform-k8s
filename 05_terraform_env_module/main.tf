module "cluster" {
  source = "./cluster"
  region = "us-east-1"
  cluster_name = "stage"
}

module "kubectl" {
#  depends_on = [module.cluster]
  source = "./kubectl"
}