# This ID is required to avoid conflicts with the secrets names inside the same platform, in case we want to use new 
# secrets created manually after the first deployment. This way we can have both versions simultaneously and migrate to 
# the new secrets without any conflicts or race conditions.
resource "random_id" "secrets_suffix" {
  for_each = toset(local.secrets_for_each)

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
