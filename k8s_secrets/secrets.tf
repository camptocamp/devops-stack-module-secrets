module "secrets_generator" {
  source = "../modules/secrets_generator"

  alertmanager_deadmanssnitch_url    = var.alertmanager_deadmanssnitch_url
  alertmanager_slack_routes_api_urls = var.alertmanager_slack_routes_api_urls
  logs_storage_secret                = var.logs_storage_secret
  metrics_storage_secret             = var.metrics_storage_secret
  oidc_client_secret                 = var.oidc_client_secret
}

resource "kubernetes_secret" "secrets" {
  for_each = toset(module.secrets_generator.secrets_for_each)

  metadata {
    name      = module.secrets_generator.secrets_to_create[each.key].name
    namespace = "secrets"
    labels = {
      "devops-stack" = "true"
      "terraform"    = "true"
    }
  }

  data = module.secrets_generator.secrets_to_create[each.key].content

  depends_on = [
    resource.null_resource.dependencies,
    resource.kubernetes_namespace.secrets_namespace,
  ]

  lifecycle {
    ignore_changes = [data] # Ignore all changes after the bootstrap to allow the users to rotate the secrets manually.
  }
}
