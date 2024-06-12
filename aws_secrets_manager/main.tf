resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "secrets" {
  count = (var.aws_iam_role != null ? var.aws_iam_role.create_role : false) || (var.aws_iam_access_key != null ? var.aws_iam_access_key.create_iam_access_key : false) ? 1 : 0

  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    # Specify the ARN of the secrets that the role can access. Since each secret is created by this module, we can 
    # easily recover these ARNs from the attributes of each Terrafom resource.
    resources = compact([for k, v in local.secrets_to_create : v != null ? resource.aws_secretsmanager_secret.secrets[k].arn : null])

    effect = "Allow"
  }
}

resource "aws_iam_policy" "secrets" {
  count = (var.aws_iam_role != null ? var.aws_iam_role.create_role : false) || (var.aws_iam_access_key != null ? var.aws_iam_access_key.create_iam_access_key : false) ? 1 : 0

  name_prefix = "external-secrets-"
  description = "External Secrets IAM policy for accessing the Secrets Manager secrets for the cluster named ${var.cluster_name}."
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

resource "kubernetes_namespace" "secrets_namespace" {
  count = var.aws_iam_access_key != null ? (var.aws_iam_access_key.create_iam_access_key || (var.aws_iam_access_key.iam_access_key != null && var.aws_iam_access_key.iam_secret_key != null) ? 1 : 0) : 0

  metadata {
    name = "secrets"
    labels = {
      "devops-stack" = "true"
    }
  }

  depends_on = [
    resource.null_resource.dependencies,
  ]
}

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
    resource.kubernetes_namespace.secrets_namespace,
  ]
}

resource "null_resource" "this" {
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
