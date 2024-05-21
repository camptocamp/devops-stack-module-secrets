variable "aws_iam_role" {
  description = <<-EOT
    IAM Role configuration to allow External Secrets to use AWS Secrets Manager as a backend.
    
    WARNING: This variable is mutually exclusive with the `aws_iam_access_key` variable, that is, if you set both at the same time, no `ClusterSecretStore` will be created.
  EOT
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
  description = <<-EOT
    AWS Access Key and Secret Key configuration to allow External Secrets to use AWS Secrets Manager as a backend.

    WARNING: This variable is mutually exclusive with the `aws_iam_role` variable, that is, if you set both at the same time, no `ClusterSecretStore` will be created.

    WARNING: This approach is required when using AWS Secrets Manager in a non-EKS cluster. However, please take notice that the IAM Access Key and IAM Secret Key are sensitive data and are stored in the Terraform state file, so you should handle it with the appropriate care. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key#secret[this notice] for more information.
  EOT
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
