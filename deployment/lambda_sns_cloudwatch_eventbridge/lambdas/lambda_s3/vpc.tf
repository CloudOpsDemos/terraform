module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = ">=5.17.0"

  name            = "${local.prefix_env}-vpc"
  cidr            = "10.0.0.0/16"
  azs             = var.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_dns_hostnames = true

  public_subnet_tags = {
    "Name"                   = "${local.prefix_env}-public-subnet"
  }

  private_subnet_tags = {
    "Name"                            = "${local.prefix_env}-private-subnet"
  }

  tags = {
    Terraform   = "true"
    Environment = local.prefix_env
  }
}