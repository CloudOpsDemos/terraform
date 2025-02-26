locals {
  env                   = "${terraform.workspace}"
  vpc_cidr              = "10.0.0.0/16"
  public_subnets        = ["10.0.1.0/24"]
  private_subnets       = ["10.0.128.0/24","10.0.129.0/24"]
  availability_zones    = ["us-west-2a", "us-west-2b"]
  cluster_name          = "general"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "${local.env}-${local.cluster_name}-vpc"
  cidr = local.vpc_cidr
  azs = [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b"
  ]
  public_subnets = local.public_subnets
  private_subnets = local.private_subnets
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}"           = "shared"
    "kubernetes.io/role/internal-elb"                       = 1
  }
}
