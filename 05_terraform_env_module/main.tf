module "cluster" {
  source = "./cluster"
  cluster_name = "stage"
}

module "kubectl" {
#  depends_on = [module.cluster]
  source = "./kubectl"
  cluster_name = var.cluster_name
}