resource "random_id" "grafana_admin_credentials_suffix" {
  byte_length = 8
}

resource "random_password" "grafana_admin_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "grafana_admin_credentials" {
  metadata {
    name      = local.secrets_names.kube_prometheus_stack.grafana_admin_credentials
    namespace = "secrets"
    labels = {
      "devops-stack" = "true"
      "terraform"    = "true"
    }
  }

  data = {
    username = "admin"
    password = random_password.grafana_admin_password.result
  }

  depends_on = [
    resource.null_resource.dependencies,
    resource.kubernetes_namespace.secrets,
  ]
}
