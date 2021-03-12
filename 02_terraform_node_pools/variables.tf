variable "cluster_name" {
  type        = string
  description = "Name to be used on all the resources as identifier."
  default     = "stage"
}

variable "eks_version" {
  default     = "1.19"
  description = "Kubernetes version to use for the cluster."
}


variable "region" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "us-east-1"
}


variable "vpc_id" {
  default     = "vpc-df0751b1"
  description = "ID of the VPC where to create the cluster resources."
}



variable "cluster_subnet_ids" {
  default     = ["subnet-0d94fa6f6e0ca3a6c","subnet-0018c37915437363f","subnet-021da8c085a0e8c83"]
  description = "A list of VPC subnet IDs which the cluster uses."
}