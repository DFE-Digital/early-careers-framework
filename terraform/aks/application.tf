locals {
  environment  = "${var.app_environment}${var.app_suffix}"
  service_name = "cpd-ecf"
}

module "application_configuration" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application_configuration?ref=testing"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  is_rails_application = true

  config_variables = {
    HOSTING_ENVIRONMENT = local.environment
    RAILS_ENV           = "deployed_development"
    DB_SSLMODE          = var.db_sslmode

    # BIGQUERY_PROJECT_ID = "ecf-bq",
    # BIGQUERY_DATASET    = "events_${var.app_environment}", TODO: work this out
    # BIGQUERY_TABLE_NAME = "events",                        TODO: work this out
    # (copied from terraform/app/modules/paas/variables.tf)
    # "DOMAIN"             = "ecf-${var.environment}.london.cloudapps.digital"
    # "GIAS_API_SCHEMA"    = "https://ea-edubase-api-prod.azurewebsites.net/edubase/schema/service.wsdl"
    # "GIAS_EXTRACT_ID"    = 13904
    # "GIAS_API_USER"      = "ecftech"
    # "GOVUK_APP_DOMAIN"   = "ecf-${var.environment}.london.cloudapps.digital"
    # "GOVUK_WEBSITE_ROOT" = "ecf-${var.environment}.london.cloudapps.digital"
  }

  secret_key_vault_short = "app"
  secret_variables = {
    DATABASE_URL = module.postgres.url
    REDIS_URL    = module.redis.url

    # AZURE_STORAGE_ACCOUNT_NAME = azurerm_storage_account.uploads.name,
    # AZURE_STORAGE_ACCESS_KEY   = azurerm_storage_account.uploads.primary_access_key,
    # AZURE_STORAGE_CONTAINER    = azurerm_storage_container.uploads.name
  }
}

module "web_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=testing"

  name   = "web"
  is_web = true

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
}

module "worker_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=testing"

  name   = "worker"
  is_web = false

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image  = var.docker_image
  command       = ["bundle", "exec", "sidekiq", "-C", "./config/sidekiq.yml"]
  probe_command = ["pgrep", "-f", "sidekiq"]
}
