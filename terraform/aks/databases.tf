module "redis" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/redis?ref=testing"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = local.service_name
  service_short         = var.service_short
  config_short          = var.config_short
  azure_capacity        = var.redis_queue_capacity
  azure_family          = var.redis_queue_family
  azure_sku_name        = var.redis_queue_sku_name

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}

module "postgres" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/postgres?ref=testing"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = local.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  azure_sku_name                 = var.postgres_flexible_server_sku
  azure_enable_high_availability = var.postgres_enable_high_availability
  azure_enable_backup_storage    = var.azure_enable_backup_storage
  use_azure                      = var.deploy_azure_backing_services
  azure_enable_monitoring        = var.enable_monitoring
  azure_extensions               = ["citext", "fuzzystrmatch", "pg_stat_statements", "pgcrypto", "plpgsql", "uuid-ossp"]
}

resource "azurerm_postgresql_flexible_server_database" "analytics" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name      = "analytics"
  server_id = module.postgres.azure_server_id
  collation = "en_US.utf8"
  charset   = "utf8"
}
