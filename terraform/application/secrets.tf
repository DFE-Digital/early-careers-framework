module "infrastructure_secrets" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/secrets?ref=testing"

  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  key_vault_short       = "inf"
}
