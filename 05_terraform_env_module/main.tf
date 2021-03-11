module "cluster" {
  source = "./cluster"
  cluster_name = "stage"
}

#module "kubectl" {
#  depends_on = [module.cluster]
#  source = "./kubectl"
#}

