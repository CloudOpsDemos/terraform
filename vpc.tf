locals {
  env                   = "${terraform.workspace}"
  vpc_cidr              = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24"]
  private_subnets  = ["10.0.128.0/24","10.0.129.0/24"]
  availability_zones    = ["us-west-2a", "us-west-2b"]
  cluster_name          = "deployment"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "deployment"
  cidr = local.vpc_cidr
  azs = [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b"
  ]
  public_subnets = local.public_subnets
  private_subnets = local.private_subnets
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_dhcp_options  = true
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

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
