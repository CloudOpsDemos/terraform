module "networking" {
#  source              = "git::https://github.com/CloudOpsDemos/terraform-modules.git//networking?ref"
  source              = "./networking"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  cidr_public_subnets  = var.cidr_public_subnets
  cidr_private_subnets = var.cidr_private_subnets
  availability_zones  = var.availability_zones
}
