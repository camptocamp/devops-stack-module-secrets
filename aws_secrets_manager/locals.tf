locals {
  secrets_names = {
    cluster_secret_store_name = "secrets-devops-stack-aws"
    kube_prometheus_stack = {
      grafana_admin_credentials = "devops-stack-grafana-admin-credentials-${resource.random_id.grafana_admin_credentials_suffix.hex}"
      foo                       = "bar" # TODO Remove this
    }
    foo = "bar" # TODO Remove this
    # TODO add remaining secrets names
  }

  helm_values = [{
    cluster_secret_stores = {
      aws = {
        name               = local.secrets_names.cluster_secret_store_name
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
