output "secrets_to_create" {
  description = "Map of secrets to be created by the caller module."
  value       = local.secrets_to_create
  sensitive   = true
}

output "secrets_names_without_secret_store" {
  description = "Names of the secrets as required by the DevOps Stack modules."
  value = {
    loki_stack = {
      logs_storage = local.secrets_to_create.logs_storage_secret.content != null ? local.secrets_to_create.logs_storage_secret.name : null
    }
    kube_prometheus_stack = {
      alertmanager_secrets       = local.secrets_to_create.alertmanager_secrets.content != null ? local.secrets_to_create.alertmanager_secrets.name : null
      grafana_admin_credentials  = local.secrets_to_create.grafana_admin_credentials.name
      metrics_storage            = local.secrets_to_create.metrics_storage_secret.content != null ? local.secrets_to_create.metrics_storage_secret.name : null
      oauth2_proxy_cookie_secret = local.secrets_to_create.oauth2_proxy_cookie_secret.name
      oidc_client_secret         = local.secrets_to_create.oidc_client_secret.name
    }
    thanos = {
      metrics_storage            = local.secrets_to_create.metrics_storage_secret.content != null ? local.secrets_to_create.metrics_storage_secret.name : null
      oauth2_proxy_cookie_secret = local.secrets_to_create.oauth2_proxy_cookie_secret.name
      oidc_client_secret         = local.secrets_to_create.oidc_client_secret.name
      redis_password             = local.secrets_to_create.thanos_redis_password.name
    }
  }
}
