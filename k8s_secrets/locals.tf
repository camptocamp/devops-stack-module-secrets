locals {
  secrets_names = {
    cluster_secret_store_name = "secrets-devops-stack-k8s"

    kube_prometheus_stack = {
      grafana_admin_credentials = "devops-stack-grafana-admin-credentials-${resource.random_id.grafana_admin_credentials_suffix.hex}"
      foo                       = "bar" # TODO Remove this
    }
    foo = "bar" # TODO Remove this
    # TODO add remaining secrets names
  }

  helm_values = [{
    cluster_secret_stores = {
      k8s = {
        name = local.secrets_names.cluster_secret_store_name
      }
    }
  }]
}
