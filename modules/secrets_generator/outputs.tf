output "secrets_for_each" {
  description = "List of secrets to create to be used by the `for_each` on the caller module."
  value       = local.secrets_for_each
}

output "secrets_to_create" {
  description = "Map of secrets to be created by the caller module."
  value       = local.secrets_to_create
  sensitive   = true
}

output "secrets_names_without_secret_store" {
  description = "Names of the secrets required by the DevOps Stack modules."
  value = {
    loki_stack = {
      logs_storage = var.logs_storage_secret != null ? local.secrets_to_create.logs_storage_secret.name : null
    }
    kube_prometheus_stack = {
      grafana_admin_credentials  = local.secrets_to_create.grafana_admin_credentials.name
      metrics_storage            = var.metrics_storage_secret != null ? local.secrets_to_create.metrics_storage_secret.name : null
      oauth2_proxy_cookie_secret = local.secrets_to_create.oauth2_proxy_cookie_secret.name
      oidc_client_secret         = local.secrets_to_create.oidc_client_secret.name
    }
  }
}
