locals {
  cluster_secret_store_name = "secrets-devops-stack-k8s"

  secrets_to_create = {
    alertmanager_secrets = var.alertmanager_slack_routes_api_urls != null || var.alertmanager_deadmanssnitch_url != null ? {
      name = "devops-stack-alertmanager-secrets-${resource.random_id.secrets_suffix.hex}"
      content = merge(
        var.alertmanager_deadmanssnitch_url != null ? {
          "deadmanssnitch-url" = var.alertmanager_deadmanssnitch_url
        } : null,
        var.alertmanager_slack_routes_api_urls != null ? {
          for route in var.alertmanager_slack_routes_api_urls : format("slack-route-%s", route.key) => route.value
        } : null
      )
    } : null

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
    oidc_client_secret = {
      name = "devops-stack-oidc-client-secret-${resource.random_id.secrets_suffix.hex}"
      content = {
        value = var.oidc_client_secret
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
  # the for_each. For each secret in the `secrets_to_create` map, we will need the key of each of the items in this 
  # list here.
  # See https://support.hashicorp.com/hc/en-us/articles/4538432032787-Variable-has-a-sensitive-value-and-cannot-be-used-as-for-each-arguments
  secrets_for_each = compact([
    var.alertmanager_slack_routes_api_urls != null || var.alertmanager_deadmanssnitch_url != null ? "alertmanager_secrets" : null,
    var.logs_storage_secret != null ? "logs_storage_secret" : null,
    var.metrics_storage_secret != null ? "metrics_storage_secret" : null,
    "grafana_admin_credentials",
    "oauth2_proxy_cookie_secret",
    "oidc_client_secret",
  ])

  helm_values = [{
    cluster_secret_stores = {
      k8s = {
        name = local.cluster_secret_store_name
      }
    }
  }]
}
