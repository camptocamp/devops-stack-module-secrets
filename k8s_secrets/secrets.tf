# This ID is required to avoid conflicts with the secrets names inside the same platform, in case we want to use new 
# secrets created manually after the first deployment. This way we can have both versions simultaneously and migrate to 
# the new secrets without any conflicts or race conditions.
resource "random_id" "secrets_suffix" {
  byte_length = 8
}

resource "random_password" "grafana_admin_password" {
  length  = 32
  special = false
}

resource "random_password" "oauth2_proxy_cookie_secret" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "secrets" {
  for_each = toset(local.secrets_for_each)

  metadata {
    name      = local.secrets_to_create[each.key].name
    namespace = "secrets"
    labels = {
      "devops-stack" = "true"
      "terraform"    = "true"
    }
  }

  data = local.secrets_to_create[each.key].content

  depends_on = [
    resource.null_resource.dependencies,
    resource.kubernetes_namespace.secrets_namespace,
  ]

  lifecycle {
    ignore_changes = all # Ignore all changes after the bootstrap to allow the users to rotate the secrets manually.
  }
}
