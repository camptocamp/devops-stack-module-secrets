resource "random_id" "grafana_admin_credentials_suffix" {
  byte_length = 8
}

resource "random_password" "grafana_admin_password" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "grafana_admin_credentials" {
  name = local.secrets_names.kube_prometheus_stack.grafana_admin_credentials

  tags = {
    "devops-stack" = "true"
    "cluster"      = var.cluster_name
  }
}

resource "aws_secretsmanager_secret_version" "grafana_admin_credentials" {
  secret_id = resource.aws_secretsmanager_secret.grafana_admin_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = resource.random_password.grafana_admin_password.result
  })
}
