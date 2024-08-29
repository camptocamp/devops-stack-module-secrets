locals {
  cluster_secret_store_name = "secrets-devops-stack-k8s"

  helm_values = [{
    cluster_secret_stores = {
      k8s = {
        name = local.cluster_secret_store_name
      }
    }
  }]
}
