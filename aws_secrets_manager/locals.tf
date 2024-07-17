locals {
  cluster_secret_store_name = "secrets-devops-stack-aws"

  secrets_to_create = {

    logs_storage_secret = var.logs_storage_secret != null ? {
      name    = "devops-stack-logs-storage-${resource.random_id.secrets_suffix.hex}"
      content = var.logs_storage_secret
    } : null

    metrics_storage_secret = var.metrics_storage_secret != null ? {
      name    = "devops-stack-metrics-storage-${resource.random_id.secrets_suffix.hex}"
      content = var.metrics_storage_secret
    } : null

    grafana_admin_credentials = {
      name = "devops-stack-grafana-admin-credentials-${resource.random_id.secrets_suffix.hex}"
      content = {
        username = "admin"
        password = resource.random_password.grafana_admin_password.result
      }
    }
    oauth2_proxy_cookie_secret = {
      name = "devops-stack-oauth2-proxy-cookie-secret-${resource.random_id.secrets_suffix.hex}"
      content = {
        value = resource.random_password.oauth2_proxy_cookie_secret.result
      }
    }

    # TODO Add remaining secrets in this map
  }

  # We use this local to iterate over the secrets_to_create because Terraform does not let us to use that directly in 
  # the for_each.
  # See https://support.hashicorp.com/hc/en-us/articles/4538432032787-Variable-has-a-sensitive-value-and-cannot-be-used-as-for-each-arguments 
  secrets_for_each = compact([
    var.logs_storage_secret != null ? "logs_storage_secret" : null,
    var.metrics_storage_secret != null ? "metrics_storage_secret" : null,
    "grafana_admin_credentials",
    "oauth2_proxy_cookie_secret",
  ])

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
