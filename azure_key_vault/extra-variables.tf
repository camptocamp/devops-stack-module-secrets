variable "node_resource_group_name" {
  description = "The managed AKS resource group name."
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  type        = string
}

variable "key_vault_name" {
  description = "The name of the key vault."
}

variable "tags" {
  description = "The tags to apply to the key vault."
  type        = map(string)
}

variable "officer_secret_on_keyvault" {
  description = "The principal ID of the officer on the key vault."
  type        = list(string)
  default     = []
}
