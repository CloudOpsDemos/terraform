locals {
  cluster_version = "1.32"
  tags = {
    Project    = "general"
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
  cert_manager_version = "v1.5.3"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name                             = local.cluster_name
  cluster_version                          = local.cluster_version
  cluster_endpoint_public_access           = true
  subnet_ids                               = module.vpc.private_subnets
  vpc_id                                   = module.vpc.vpc_id
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled = true
    node_pools = ["general-purpose"]
  }

  tags = local.tags
}


