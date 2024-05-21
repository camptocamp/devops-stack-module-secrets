locals {
  helm_values = [{
    external-secrets = {
      replicaCount = var.replicas.external_secrets
      leaderElect  = var.replicas.external_secrets > 1 # FIXME I do not understand if this is required or not, like in the Reloader chart
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
