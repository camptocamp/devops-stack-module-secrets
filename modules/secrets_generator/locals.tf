locals {
  # List of secrets that will be created by this module. This list is used to do a for_each for the random_id resource
  # to generate a unique suffix for each secret. This is required to avoid Terraform throwing a cycle error if we tried 
  # iterating over the secrets_to_create map directly. 
  secrets_keys = [
    "alertmanager_secrets",
    "logs_storage_secret",
    "metrics_storage_secret",
    "grafana_admin_credentials",
    "oauth2_proxy_cookie_secret",
    "oidc_client_secret"
  ]

  secrets_to_create = {
    alertmanager_secrets = {
      name = "devops-stack-alertmanager-secrets-${resource.random_id.secrets_suffix["alertmanager_secrets"].hex}"
      content = merge(
        var.alertmanager_deadmanssnitch_url != null ? {
          "deadmanssnitch-url" = var.alertmanager_deadmanssnitch_url
        } : null,
        var.alertmanager_slack_routes_api_urls != null ? {
          for k, v in var.alertmanager_slack_routes_api_urls : format("slack-route-%s", k) => v
        } : null
      )
    }

    logs_storage_secret = {
      name    = "devops-stack-logs-storage-${resource.random_id.secrets_suffix["logs_storage_secret"].hex}"
      content = var.logs_storage_secret
    }

    metrics_storage_secret = {
      name    = "devops-stack-metrics-storage-${resource.random_id.secrets_suffix["metrics_storage_secret"].hex}"
      content = var.metrics_storage_secret
    }

    grafana_admin_credentials = {
      name = "devops-stack-grafana-admin-credentials-${resource.random_id.secrets_suffix["grafana_admin_credentials"].hex}"
      content = {
        username = "admin"
        password = resource.random_password.grafana_admin_password.result
      }
    }
    oauth2_proxy_cookie_secret = {
      name = "devops-stack-oauth2-proxy-cookie-secret-${resource.random_id.secrets_suffix["oauth2_proxy_cookie_secret"].hex}"
      content = {
        value = resource.random_password.oauth2_proxy_cookie_secret.result
      }
    }
    oidc_client_secret = {
      name = "devops-stack-oidc-client-secret-${resource.random_id.secrets_suffix["oidc_client_secret"].hex}"
      content = {
        value = var.oidc_client_secret
      }
    }

    # TODO Add remaining secrets in this map
  }
}
