# data.aws_caller_identity.current.account_id
# data.aws_caller_identity.current.arn
# data.aws_caller_identity.current.user_id
# data.aws_region.current.name

locals {
  prefix = "msobo"
  prefix_env = "${local.prefix}-${var.env_name}"
  cluster_name = "${local.prefix_env}-eks-cluster"
  cluster_version = var.eks_cluster_version

  aws_account_id = data.aws_caller_identity.current.account_id

  ebs_claim_name = "${local.prefix_env}-ebs-storage-pv-claim"
  
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "arbitrick" {
  name = "arbitrick.click"
}

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      version = ">= 5.83"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "msobo-terraform"
    region         = "us-west-2"
    profile        = "msobo"
    key            = "msobo-terraform.tfstate"
    dynamodb_table = "msobo-terraform-state-lock"
  }
}

provider "aws" {
  profile = "msobo"
  region  = "us-west-2"
}

# Kubernetes provider
data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.cluster_auth.token
# }

# ADD KUBE_CONFIG_PATH TO ENVIRONMENT
# OR https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234