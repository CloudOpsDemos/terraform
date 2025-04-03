# Add policy to add permissions to change records in Route53
resource "aws_iam_policy" "eks_dns" {
  name        = "eks_external_dns"
  description = "Policy to allow EKS to change records in Route53"
  policy      = data.aws_iam_policy_document.eks_dns.json    
}

data "aws_iam_policy_document" "eks_dns" {
  statement {
    actions = ["route53:ChangeResourceRecordSets"]
    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.arbitrick.zone_id}"
    ]
  }
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}

module "eks_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.1.0"
  create_role                   = true
  role_name                     = "eks-external-dns"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.eks_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.namespaces["infrastructure"].metadata[0].name}:external-dns"]
  depends_on = [ module.eks ]
}

resource "kubernetes_service_account" "eks_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.namespaces["infrastructure"].metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.eks_dns.iam_role_arn
    }
  }
}

locals {
  eks_dns_version = {
    repository = "https://kubernetes-sigs.github.io/external-dns/"
    chart_version    = "1.15.1"
    app_version      = "v0.15.1"
  }
}

resource "helm_release" "dns" {
  name       = "external-dns"
  version    = local.eks_dns_version.chart_version
  repository = local.eks_dns_version.repository
  chart      = "external-dns"
  namespace  = kubernetes_namespace.namespaces["infrastructure"].metadata[0].name
  values = [yamlencode({
    image = {
      repository = "registry.k8s.io/external-dns/external-dns"
      tag        = local.eks_dns_version.app_version
    }
    serviceAccount = {
      name   = kubernetes_service_account.eks_dns.metadata[0].name
      create = false
    }
    txtOwnerId = data.aws_route53_zone.arbitrick.zone_id
    resources = {
      limits = {
        cpu = "100m"
        memory = "100Mi"
      }
      requests = {
        cpu = "100m"
        memory = "100Mi"
      }
    }
  })]

  depends_on = [
    module.eks
  ]
}