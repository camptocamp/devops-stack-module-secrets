variable "alertmanager_deadmanssnitch_url" {
  description = "URL of a Dead Man's Snitch service Alertmanager should report to (by default this reporting is disabled)."
  type        = string
  default     = null
  sensitive   = true
}

variable "alertmanager_slack_routes_api_urls" {
  description = "List of Slack URLs you received when configuring a webhook integration. Should be passed as a set of strings in the format `name = `api_url`, where `name` should be the same value as the `name` attribute in the `alertmanager_slack_routes` variable of the kube-prometheus-stack module."
  type        = set(string)
  default     = null
  sensitive   = true
}

# TODO Enable when starting to work on the Argo CD secrets
# variable "argocd_pipeline_token" {
#   description = "Argo CD pipeline token to authenticate with the Argo CD API."
#   type        = string
#   nullable    = false
#   sensitive = true
# }

variable "logs_storage_secret" {
  description = <<-EOT
    Access Key and Secret Key for the bucket where the logs will be stored.

    This is required *only* for the deployments using the SKS, Scaleway and KinD variants, since these platforms only support this form of authentication to access the S3 buckets.
  EOT
  type = object({
    access_key = string
    secret_key = string
  })
  default   = null
  sensitive = true
}

variable "metrics_storage_secret" {
  description = <<-EOT
    Access Key and Secret Key for the bucket where the archived metrics will be stored.
    
    This is required *only* for the deployments using the SKS, Scaleway and KinD variants, since these platforms only support this form of authentication to access the S3 buckets.

    IMPORTANT: This variable is not required if you are not using the Thanos module.
  EOT
  type = object({
    access_key = string
    secret_key = string
  })
  default   = null
  sensitive = true
}

variable "oidc_client_secret" {
  description = "OIDC client secret to authenticate with the OIDC provider."
  type        = string
  nullable    = false
  sensitive   = true
}
