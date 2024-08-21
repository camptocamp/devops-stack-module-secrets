# This ID is required to avoid conflicts with the secrets names inside the same platform, in case there are multiple 
# deployments inside the same platform.
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

resource "aws_secretsmanager_secret" "secrets" {
  for_each = toset(local.secrets_for_each)

  name = local.secrets_to_create[each.key].name

  tags = {
    "devops-stack" = "true"
    "terraform"    = "true"
    "cluster"      = var.cluster_name
  }

  lifecycle {
    # TODO Evaluate if only the tags should be ignored, in order to have a static secret name!
    ignore_changes = all # Ignore all changes after the bootstrap to allow the users to rotate the secrets manually.
  }
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each = toset(local.secrets_for_each)

  secret_id     = resource.aws_secretsmanager_secret.secrets[each.key].id
  secret_string = jsonencode(local.secrets_to_create[each.key].content)

  lifecycle {
    ignore_changes = all # Ignore all changes after the bootstrap to allow the users to rotate the secrets manually.
  }
}
