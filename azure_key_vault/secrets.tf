# This ID is required to avoid conflicts with the secrets names inside the same platform, in case there are multiple 
# deployments inside the same platform.
resource "random_id" "secrets_suffix" {
  byte_length = 8
}

resource "random_password" "grafana_admin_password" {
  length  = 32
  special = false
}

resource "azurerm_user_assigned_identity" "keyvault" {
  resource_group_name = data.azurerm_resource_group.node_resource_group.name
  location            = data.azurerm_resource_group.node_resource_group.location
  name                = var.key_vault_name
}

resource "azurerm_federated_identity_credential" "keyvault" {
  name                = var.key_vault_name
  resource_group_name = var.node_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.cluster_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.keyvault.id
  subject             = "system:serviceaccount::secrets:secrets-external-secrets"
}

resource "azurerm_key_vault" "main" {
  name                      = lower("${var.key_vault_name}")
  location                  = data.azurerm_resource_group.node_resource_group.location
  resource_group_name       = data.azurerm_resource_group.node_resource_group.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  tags                      = var.tags
  enable_rbac_authorization = true
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_role_assignment" "officer_on_keyvault" {
  count                = local.number_of_officer_on_keyvault
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.officer_secret_on_keyvault[count.index]
}

resource "azurerm_role_assignment" "reader_on_keyvault" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.keyvault.principal_id
}


resource "azurerm_key_vault_secret" "keys" {
  for_each     = toset(local.secrets_for_each)
  name         = replace(local.secrets_to_create[each.key].name, "_", "-")
  value        = jsonencode(local.secrets_to_create[each.key].content)
  key_vault_id = azurerm_key_vault.main.id

  lifecycle {
    ignore_changes = all # Ignore all changes after the bootstrap to allow the users to rotate the secrets manually.
  }
}
