provider "google" {
  project = "ecf-bq"
}

module "dfe_analytics" {
  count  = var.enable_dfe_analytics_federated_auth ? 1 : 0
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/dfe_analytics?ref=stable"

  azure_resource_prefix = var.azure_resource_prefix
  cluster               = var.cluster
  namespace             = var.namespace
  service_short         = var.service_short
  environment           = local.environment
  gcp_dataset           = var.dataset_name
}
