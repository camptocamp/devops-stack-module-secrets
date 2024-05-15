# FIXME This file needs to probably be in a different variant of the module, otherwise we would have some issues with 
# requiring providers that are not needed (for example, requiring the AWS Terraform provider when using Azure Key Vault).

data "aws_region" "current" {
  count = var.aws_iam_role != null || var.aws_iam_access_key != null ? 1 : 0
}

data "aws_secretsmanager_secrets" "secrets" {
  count = var.aws_iam_role != null || var.aws_iam_access_key != null ? 1 : 0

  filter {
    name   = "tag-value"
    values = [var.cluster_name]
  }
  filter {
    name   = "tag-key"
    values = ["devops-stack"]
  }
}

data "aws_iam_policy_document" "secrets" {
  count = (var.aws_iam_role != null ? var.aws_iam_role.create_role : false) || (var.aws_iam_access_key != null ? var.aws_iam_access_key.create_iam_access_key : false) ? 1 : 0

  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = data.aws_secretsmanager_secrets.secrets[0].arns

    effect = "Allow"
  }
}

resource "aws_iam_policy" "secrets" {
  count = (var.aws_iam_role != null ? var.aws_iam_role.create_role : false) || (var.aws_iam_access_key != null ? var.aws_iam_access_key.create_iam_access_key : false) ? 1 : 0

  name_prefix = "external-secrets-"
  description = "External Secrets IAM policy for accessing the Secrets Manager secrets."
  policy      = data.aws_iam_policy_document.secrets[0].json

  tags = {
    "devops-stack" = "true"
    "cluster"      = var.cluster_name
  }
}

module "iam_assumable_role_secrets" {
  source                     = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                    = "~> 5.0"
  create_role                = var.aws_iam_role != null ? var.aws_iam_role.create_role : false
  number_of_role_policy_arns = 1
  role_name_prefix           = "external-secrets-"

  provider_url     = try(trimprefix(var.aws_iam_role.cluster_oidc_issuer_url, "https://"), "")
  role_policy_arns = [try(resource.aws_iam_policy.secrets[0].arn, null)]

  # List of ServiceAccounts that have permission to attach to this IAM role
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:secrets:secrets-external-secrets"
  ]
}

resource "aws_iam_user" "secrets" {
  count = var.aws_iam_access_key != null ? (var.aws_iam_access_key.create_iam_access_key ? 1 : 0) : 0

  name          = "external-secrets-${var.cluster_name}"
  force_destroy = true

  tags = {
    "devops-stack" = "true"
    "cluster"      = var.cluster_name
  }
}

resource "aws_iam_access_key" "secrets" {
  count = var.aws_iam_access_key != null ? (var.aws_iam_access_key.create_iam_access_key ? 1 : 0) : 0

  user = resource.aws_iam_user.secrets[0].name
}

resource "aws_iam_user_policy_attachment" "secrets" {
  count = var.aws_iam_access_key != null ? (var.aws_iam_access_key.create_iam_access_key ? 1 : 0) : 0

  user       = resource.aws_iam_user.secrets[0].name
  policy_arn = resource.aws_iam_policy.secrets[0].arn
}

# TODO Remove this when further tests have been made
# resource "kubernetes_namespace" "secrets_namespace" {
#   count = var.aws_iam_access_key != null ? (var.aws_iam_access_key.create_iam_access_key || (var.aws_iam_access_key.iam_access_key != null && var.aws_iam_access_key.iam_secret_key != null) ? 1 : 0) : 0

#   metadata {
#     name = "secrets"
#   }

#   depends_on = [
#     resource.null_resource.dependencies,
#   ]
# }

resource "kubernetes_secret" "aws_secrets_manager_iam_credentials" {
  count = var.aws_iam_access_key != null ? (var.aws_iam_access_key.create_iam_access_key || (var.aws_iam_access_key.iam_access_key != null && var.aws_iam_access_key.iam_secret_key != null) ? 1 : 0) : 0

  metadata {
    name      = "secrets-aws-secrets-manager-credentials"
    namespace = "secrets"
  }

  data = {
    "access-key" = var.aws_iam_access_key.create_iam_access_key ? resource.aws_iam_access_key.secrets[0].id : var.aws_iam_access_key.iam_access_key
    "secret-key" = var.aws_iam_access_key.create_iam_access_key ? resource.aws_iam_access_key.secrets[0].secret : var.aws_iam_access_key.iam_secret_key
  }

  depends_on = [
    resource.null_resource.dependencies,
    resource.argocd_application.this,
  ]
}


