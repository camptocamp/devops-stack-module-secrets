resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "node_resource_group" {
  name = var.node_resource_group_name

  depends_on = [
    resource.null_resource.dependencies
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
}
