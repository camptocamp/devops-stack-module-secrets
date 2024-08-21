locals {
  cluster_secret_store_name = "secrets-devops-stack-azure"
  number_of_officer_on_keyvault       = length(var.officer_secret_on_keyvault)
  number_of_reader_secret_on_keyvault = azurerm_user_assigned_identity.keyvault.principal_id
  secrets_to_create = {
    logs_storage_secret = var.logs_storage_secret != null ? {
      name    = "devops-stack-logs-storage-${resource.random_id.secrets_suffix.hex}"
      content = var.logs_storage_secret
    } : null

    metrics_storage_secret = var.metrics_storage_secret != null ? {
      name    = "devops-stack-metrics-storage-${resource.random_id.secrets_suffix.hex}"
      content = var.metrics_storage_secret
    } : null

    grafana_admin_credentials = {
      name = "devops-stack-grafana-admin-credentials-${resource.random_id.secrets_suffix.hex}"
      content = {
        username = "admin"
        password = resource.random_password.grafana_admin_password.result
      }
    }
  }


  # We use this local to iterate over the secrets_to_create because Terraform does not let us to use that directly in 
  # the for_each.
  # See https://support.hashicorp.com/hc/en-us/articles/4538432032787-Variable-has-a-sensitive-value-and-cannot-be-used-as-for-each-arguments 
  secrets_for_each = compact([
    var.logs_storage_secret != null ? "logs_storage_secret" : null,
    var.metrics_storage_secret != null ? "metrics_storage_secret" : null,
    "grafana_admin_credentials"
  ])

  helm_values = [{
    cluster_secret_stores = {
      azure = {
        name      = resource.azurerm_key_vault.main.name
        vault_url = resource.azurerm_key_vault.main.vault_uri
      }
    }
    external-secrets = {
      serviceAccount = {
        annotations = {
          "azure.workload.identity/client-id" = azurerm_user_assigned_identity.keyvault.client_id
          "azure.workload.identity/tenant-id" = data.azurerm_client_config.current.tenant_id
        }
      }
    }
  }]
}
