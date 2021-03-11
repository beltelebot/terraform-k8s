module "cluster" {
  source = "./cluster"
  cluster_name = "stage"
}

#module "kubectl" {
#  depends_on = [module.cluster]
#  source = "./kubectl"
#}

output "cluster_name" {
  value       = module.cluster.cluster_name
  description = "Cluster name"
}