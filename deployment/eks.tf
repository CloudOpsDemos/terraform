# EKS Cluster using Auto Mode
module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.30"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # *** AWS EKS Auto Mode is enabled here ***
  # Auto compute, storage, and load balancing are enabled here
  # This replaces the more complex eks_managed_node_groups block
  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  # Cluster access entry
  enable_cluster_creator_admin_permissions = true

  # Others
  cloudwatch_log_group_retention_in_days = 7

  # Tagging
  tags = {
    Environment = local.prefix_env
    Terraform   = "true"

    # Ensure workspace check logic runs before resources created
    always_zero = length(null_resource.check_workspace)
  }

  # Transient failures in creating StorageClass, PersistentVolumeClaim, 
  # ServiceAccount, Deployment, were observed due to RBAC propagation not 
  # completed. Therefore raising this from its default 30s 
  dataplane_wait_duration = "60s"

}

