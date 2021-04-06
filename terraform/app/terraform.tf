/*
For username / password authentication:
- user
- password
For SSO authentication
- sso_passcode
- store_tokens_path = /path/to/local/file
*/

provider cloudfoundry {
  api_url           = var.paas_api_url
  password          = var.paas_password != "" ? var.paas_password : null
  sso_passcode      = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
  store_tokens_path = "./tokens"
  user              = var.paas_user != "" ? var.paas_user : null
}

provider "statuscake" {
  username = var.statuscake_username
  apikey   = var.statuscake_apikey
}

/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {

  backend "s3" {
    key     = "terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

module paas {
  source = "./modules/paas"

  environment                       = var.environment
  app_docker_image                  = var.paas_app_docker_image
  app_env_values                    = local.paas_app_env_values
  app_start_timeout                 = var.paas_app_start_timeout
  app_stopped                       = var.paas_app_stopped
  service_name                      = local.service_name
  postgres_service_plan             = var.paas_postgres_service_plan
  space_name                        = var.paas_space_name
  web_app_deployment_strategy       = var.paas_web_app_deployment_strategy
  web_app_instances                 = var.paas_web_app_instances
  web_app_memory                    = var.paas_web_app_memory
  web_app_start_command             = var.paas_web_app_start_command
  logstash_url                      = var.logstash_url
  govuk_hostnames                   = var.govuk_hostnames
}

module "statuscake" {
  source = "./modules/statuscake"

  environment       = var.environment
  service_name      = local.service_name
  statuscake_alerts = var.statuscake_alerts
}