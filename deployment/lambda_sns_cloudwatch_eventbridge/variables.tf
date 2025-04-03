variable "env_name" {
  description = "Unique identifier for tfvars configuration used"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy the EKS cluster"
  type        = string
}

variable "azs" {
  description = "Availability zones for the EKS cluster"
  type        = list(string)
}