output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency. It takes the ID that comes from the main module and passes it along to the code that called this variant in the first place."
  value       = module.secrets.id
}

output "secrets_names" {
  description = "Name of the `ClusterSecretStore` used by the External Secrets Operator and the names of the secrets required by the DevOps Stack modules."
  value = {
    cluster_secret_store_name = local.cluster_secret_store_name
    loki_stack = {
      logs_storage = var.logs_storage_secret != null ? local.secrets_to_create.logs_storage_secret.name : null
    }
    kube_prometheus_stack = {
      metrics_storage            = var.metrics_storage_secret != null ? local.secrets_to_create.metrics_storage_secret.name : null
      grafana_admin_credentials  = local.secrets_to_create.grafana_admin_credentials.name
      oidc_client_secret         = local.secrets_to_create.oidc_client_secret.name
      oauth2_proxy_cookie_secret = local.secrets_to_create.oauth2_proxy_cookie_secret.name
    }
  }
}
