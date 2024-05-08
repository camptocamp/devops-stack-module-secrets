#######################
## Standard variables
#######################

variable "cluster_name" {
  description = "Name given to the cluster. Value used for naming some the resources created by the module."
  type        = string
}

variable "base_domain" {
  description = "Base domain of the cluster. Value used for the ingress' URL of the application."
  type        = string
}

variable "argocd_project" {
  description = "Name of the Argo CD AppProject where the Application should be created. If not set, the Application will be created in a new AppProject only for this Application."
  type        = string
  default     = null
}

variable "argocd_labels" {
  description = "Labels to attach to the Argo CD Application resource."
  type        = map(string)
  default     = {}
}

variable "destination_cluster" {
  description = "Destination cluster where the application should be deployed."
  type        = string
  default     = "in-cluster"
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "v1.0.0" # x-release-please-version
}

variable "cluster_issuer" {
  description = "SSL certificate issuer to use. Usually you would configure this value as `letsencrypt-staging` or `letsencrypt-prod` on your root `*.tf` files."
  type        = string
  default     = "selfsigned-issuer"
}

variable "helm_values" {
  description = "Helm chart value overrides. They should be passed as a list of HCL structures."
  type        = any
  default     = []
}

variable "deep_merge_append_list" {
  description = "A boolean flag to enable/disable appending lists instead of overwriting them."
  type        = bool
  default     = false
}

variable "app_autosync" {
  description = "Automated sync options for the Argo CD Application resource."
  type = object({
    allow_empty = optional(bool)
    prune       = optional(bool)
    self_heal   = optional(bool)
  })
  default = {
    allow_empty = false
    prune       = true
    self_heal   = true
  }
}

variable "dependency_ids" {
  description = "IDs of the other modules on which this module depends on."
  type        = map(string)
  default     = {}
}

#######################
## Module variables
#######################

variable "enable_service_monitor" {
  description = "Enable Prometheus ServiceMonitor in the Helm chart."
  type        = bool
  default     = true
}

variable "resources" {
  description = <<-EOT
    Resource limits and requests for External Secrets's and Reloader's components. Follow the style on https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/[official documentation] to understand the format of the values.

    IMPORTANT: These are not production values. You should always adjust them to your needs.
  EOT
  type = object({

    external_secrets_operator = optional(object({
      requests = optional(object({
        cpu    = optional(string, "10m")
        memory = optional(string, "32Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string)
        memory = optional(string, "64Mi")
      }), {})
    }), {})

    external_secrets_webhook = optional(object({
      requests = optional(object({
        cpu    = optional(string, "10m")
        memory = optional(string, "32Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string)
        memory = optional(string, "64Mi")
      }), {})
    }), {})

    external_secrets_cert_controller = optional(object({
      requests = optional(object({
        cpu    = optional(string, "10m")
        memory = optional(string, "32Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string)
        memory = optional(string, "64Mi")
      }), {})
    }), {})

    reloader = optional(object({
      requests = optional(object({
        cpu    = optional(string, "10m")
        memory = optional(string, "32Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string)
        memory = optional(string, "64Mi")
      }), {})
    }), {})

  })
  default = {}
}

variable "replicas" {
  description = "Number of replicas for the External Secrets and Reloader components."
  type = object({
    external_secrets = number
    reloader         = number
  })
  default = {
    external_secrets = 1
    reloader         = 1
  }
  nullable = false

  validation {
    condition     = var.replicas.external_secrets >= 1
    error_message = "The number of replicas for the External Secrets component must be greater than or equal to 1."
  }

  validation {
    condition     = var.replicas.reloader >= 1
    error_message = "The number of replicas for the Reloader component must be greater than or equal to 1."
  }
}

variable "auto_reload_all" {
  description = "TODO" # TODO
  type        = bool
  default     = false
  nullable    = false
}

variable "aws_iam_role" {
  description = "IAM Role configuration to allow External Secrets to use AWS Secrets Manager as a backend. This variable is mutually exclusive with the `aws_iam_access_key` variable, that is, if you set both at the same time, no `ClusterSecretStore` will be created."
  type = object({
    create_role             = optional(bool, false)
    iam_role_arn            = optional(string, null)
    cluster_oidc_issuer_url = optional(string, null)
  })
  default = null

  validation {
    condition     = try(var.aws_iam_role.create_role ? var.aws_iam_role.cluster_oidc_issuer_url != null : var.aws_iam_role.iam_role_arn != null, true)
    error_message = "If you want to create a role, you need to provide the OIDC issuer's URL for the EKS cluster. Otherwise, you need to provide the ARN of the IAM role you created."
  }
}

variable "aws_iam_access_key" {
  description = "AWS Access Key and Secret Key configuration to allow External Secrets to use AWS Secrets Manager as a backend. This variable is mutually exclusive with the `aws_iam_role` variable, that is, if you set both at the same time, no `ClusterSecretStore` will be created."
  type = object({
    create_iam_access_key = optional(bool, false)
    iam_access_key        = optional(string, null)
    iam_secret_key        = optional(string, null)
  })
  default = null

  validation {
    condition     = try(var.aws_iam_access_key.create_iam_access_key ? (var.aws_iam_access_key.iam_access_key == null && var.aws_iam_access_key.iam_secret_key == null) : (var.aws_iam_access_key.iam_access_key != null && var.aws_iam_access_key.iam_secret_key != null), true)
    error_message = "If you do not want to create an IAM access key, you need to provide an access key and a secret key. If it is not the case, you should not set the attributes `iam_access_key` and `iam_secret_key."
  }
}
