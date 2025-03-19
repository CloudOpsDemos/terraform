# Add policy to add permissions to change records in Route53
resource "aws_iam_policy" "eks_s3" {
  name        = "eks_s3"
  description = "Policy to allow EKS to list S3 instances"
  policy      = data.aws_iam_policy_document.eks_s3.json    
}

data "aws_iam_policy_document" "eks_s3" {
  statement {
    actions = [
                "s3:Get*",
                "s3:List*",
                "s3:Describe*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ]
    resources = [
      "*"
    ]
  }
}

module "eks_s3" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.1.0"
  create_role                   = true
  role_name                     = "eks-s3"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.eks_s3.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.namespaces["infrastructure"].metadata[0].name}:eks-s3"]
  depends_on = [ module.eks ]
}

resource "kubernetes_service_account" "eks_s3" {
  metadata {
    name      = "eks-s3"
    namespace = kubernetes_namespace.namespaces["infrastructure"].metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.eks_s3.iam_role_arn
    }
  }
}
