resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "kubernetes_namespace" "secrets" {
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

resource "null_resource" "this" {
  depends_on = [
    resource.null_resource.dependencies,
    resource.kubernetes_namespace.secrets,
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
  dependency_ids         = merge(var.dependency_ids, { "this" = resource.null_resource.this.id })

  resources       = var.resources
  replicas        = var.replicas
  auto_reload_all = var.auto_reload_all
}
