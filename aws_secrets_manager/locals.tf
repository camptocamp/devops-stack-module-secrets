locals {
  cluster_secret_store_name = "secrets-devops-stack-aws"

  helm_values = [{
    cluster_secret_stores = {
      aws = {
        name               = local.cluster_secret_store_name
        region             = data.aws_region.current.name
        use_iam_role       = var.aws_iam_role != null && var.aws_iam_access_key == null
        use_iam_access_key = var.aws_iam_role == null && var.aws_iam_access_key != null
      }
    }

    external-secrets = {
      serviceAccount = {
        annotations = var.aws_iam_role != null ? {
          "eks.amazonaws.com/role-arn" = var.aws_iam_role.create_role ? module.iam_assumable_role_secrets.iam_role_arn : var.aws_iam_role.iam_role_arn
        } : null
      }
    }
  }]
}
