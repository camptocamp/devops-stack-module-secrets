module "secrets_generator" {
  source = "../modules/secrets_generator"

  alertmanager_deadmanssnitch_url    = var.alertmanager_deadmanssnitch_url
  alertmanager_slack_routes_api_urls = var.alertmanager_slack_routes_api_urls
  logs_storage_secret                = var.logs_storage_secret
  metrics_storage_secret             = var.metrics_storage_secret
  oidc_client_secret                 = var.oidc_client_secret
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = toset(module.secrets_generator.secrets_for_each)

  name = module.secrets_generator.secrets_to_create[each.key].name

  tags = {
    "devops-stack" = "true"
    "terraform"    = "true"
    "cluster"      = var.cluster_name
  }

  lifecycle {
    ignore_changes = [tags] # Ignore all changes after the bootstrap to allow the users to rotate the secrets manually.
  }
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each = toset(module.secrets_generator.secrets_for_each)

  secret_id     = resource.aws_secretsmanager_secret.secrets[each.key].id
  secret_string = jsonencode(module.secrets_generator.secrets_to_create[each.key].content)

  lifecycle {
    ignore_changes = [secret_string] # Ignore all changes after the bootstrap to allow the users to rotate the secrets manually.
  }
}
