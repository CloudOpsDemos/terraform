variable "env_name" {
  description = "Unique identifier for tfvars configuration used"
  type        = string
}

variable "node_instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy the EKS cluster"
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS version"
  type        = string
  default     = "1.32"
}

variable "azs" {
  description = "Availability zones for the EKS cluster"
  type        = list(string)
}