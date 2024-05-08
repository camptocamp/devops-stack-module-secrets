locals {
  helm_values = [{
    aws_cluster_secret_store = (var.aws_iam_role != null || var.aws_iam_access_key != null) && !(var.aws_iam_role != null && var.aws_iam_access_key != null) ? {
      name               = "secrets-devops-stack-aws"
      region             = data.aws_region.current[0].name
      use_iam_role       = var.aws_iam_role != null ? (var.aws_iam_role.create_role || var.aws_iam_role.iam_role_arn != null) : false
      use_iam_access_key = var.aws_iam_access_key != null ? (var.aws_iam_access_key.create_iam_access_key || (var.aws_iam_access_key.iam_access_key != null && var.aws_iam_access_key.iam_secret_key != null)) : false
    } : null

    external-secrets = {
      replicaCount = var.replicas.external_secrets
      leaderElect  = var.replicas.external_secrets > 1 # FIXME I do not understand if this is required or not like in the Reloader chart
      resources = {
        requests = { for k, v in var.resources.external_secrets_operator.requests : k => v if v != null }
        limits   = { for k, v in var.resources.external_secrets_operator.limits : k => v if v != null }
      }
      webhook = {
        resources = {
          requests = { for k, v in var.resources.external_secrets_webhook.requests : k => v if v != null }
          limits   = { for k, v in var.resources.external_secrets_webhook.limits : k => v if v != null }
        }
      }
      certController = {
        resources = {
          requests = { for k, v in var.resources.external_secrets_cert_controller.requests : k => v if v != null }
          limits   = { for k, v in var.resources.external_secrets_cert_controller.limits : k => v if v != null }
        }
      }
      serviceMonitor = {
        enabled = var.enable_service_monitor
      }
      serviceAccount = {
        annotations = merge(
          (var.aws_iam_role != null ? (var.aws_iam_role.create_role || var.aws_iam_role.iam_role_arn != null) : false) ? {
            "eks.amazonaws.com/role-arn" = var.aws_iam_role.create_role ? module.iam_assumable_role_secrets.iam_role_arn : var.aws_iam_role.iam_role_arn
          } : null,
          true ? {} : {} # TODO This is a placeholder to add the annotation for AKS deployments
        )
      }
    }

    reloader = {
      reloader = {
        autoReloadAll = var.auto_reload_all
        enableHA      = var.replicas.reloader > 1
        deployment = {
          replicas = var.replicas.reloader
          resources = {
            requests = { for k, v in var.resources.reloader.requests : k => v if v != null }
            limits   = { for k, v in var.resources.reloader.limits : k => v if v != null }
          }
        }
        podMonitor = {
          enabled = var.enable_service_monitor
        }
      }
    }
  }]
}
