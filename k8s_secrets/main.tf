resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "kubernetes_namespace" "secrets_namespace" {
  metadata {
    name = "secrets"
    labels = {
      "terraform" = "true"
    }
  }

  depends_on = [
    resource.null_resource.dependencies,
  ]
}

module "secrets" {
  source = "../"

  cluster_name           = var.cluster_name
  base_domain            = var.base_domain
  argocd_project         = var.argocd_project
  argocd_labels          = var.argocd_labels
  destination_cluster    = var.destination_cluster
  target_revision        = var.target_revision
  enable_service_monitor = var.enable_service_monitor
  cluster_issuer         = var.cluster_issuer
  helm_values            = concat(local.helm_values, var.helm_values)
  deep_merge_append_list = var.deep_merge_append_list
  app_autosync           = var.app_autosync
  dependency_ids         = var.dependency_ids

  resources       = var.resources
  replicas        = var.replicas
  auto_reload_all = var.auto_reload_all

  # Although these variables are not used in the core module, they are propagated there only to maintain them as a 
  # requirement when calling the variants.
  logs_storage_secret    = var.logs_storage_secret
  metrics_storage_secret = var.metrics_storage_secret
  oidc_client_secret     = var.oidc_client_secret
}
