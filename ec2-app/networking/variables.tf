variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR value"
}

variable "cidr_public_subnets" {
  type        = list(string)
  description = "Public subnets CIDR value"
}

variable "cidr_private_subnets" {
  type        = list(string)
  description = "Public subnets CIDR value"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
}

variable "env" {
  type        = string
  description = "Environment - tf workspace"
}
