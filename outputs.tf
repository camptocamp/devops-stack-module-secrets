output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "cluster_secret_stores" {
  description = "The names of the cluster stores that were created by the module."
  value = merge(
    local.helm_values[0].aws_cluster_secret_store != null ? { "aws-secrets-manager" = local.helm_values[0].aws_cluster_secret_store.name } : {},
    # TODO Add remaining secrets backend when they are added
  )
}
