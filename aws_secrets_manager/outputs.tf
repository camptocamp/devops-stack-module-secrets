output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency. It takes the ID that comes from the main module and passes it along to the code that called this variant in the first place."
  value       = module.secrets.id
}

output "secrets_names" {
  description = "Name of the `ClusterSecretStore` used by the External Secrets Operator and the names of the secrets required by the DevOps Stack modules."
  value = merge({
    cluster_secret_store_name = local.cluster_secret_store_name
    },
    module.secrets_generator.secrets_names_without_secret_store
  )
}
