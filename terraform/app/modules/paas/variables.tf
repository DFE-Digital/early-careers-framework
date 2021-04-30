variable environment {
}

variable app_docker_image {
}

variable app_env_values {
}

variable app_start_timeout {
  default = 300
}

variable app_stopped {
  default = false
}

variable postgres_service_plan {
}

variable service_name {
}
variable space_name {
}

variable web_app_deployment_strategy {
}

variable web_app_instances {
}

variable web_app_memory {
}

variable web_app_start_command {
}


variable worker_app_start_command {
}

variable worker_app_instances {
}

variable worker_app_memory {
}

variable worker_app_deployment_strategy {
}

variable logstash_url {
}

variable govuk_hostnames {
  type    = list(string)
  default = []
}

locals {

  app_env_domain = {
    "DOMAIN"             = "ecf-${var.environment}.london.cloudapps.digital"
    "GIAS_API_SCHEMA"    = "https://ea-edubase-api-prod.azurewebsites.net/edubase/schema/service.wsdl"
    "GIAS_EXTRACT_ID"    = 13904
    "GIAS_API_USER"      = "ecftech"
    "GOVUK_APP_DOMAIN"   = "ecf-${var.environment}.london.cloudapps.digital"
    "GOVUK_WEBSITE_ROOT" = "ecf-${var.environment}.london.cloudapps.digital"
  }
  app_environment = merge(
    local.app_env_domain,
    var.app_env_values #Because of merge order, if present, the value of DOMAIN in .tfvars will overwrite app_env_domain
  )
  app_cloudfoundry_service_instances = [
    cloudfoundry_service_instance.postgres_instance.id,
    cloudfoundry_service_instance.csv_bucket.id,
    cloudfoundry_user_provided_service.logging.id,
  ]
  app_service_bindings = concat(
    local.app_cloudfoundry_service_instances,
  )
  csv_bucket_name       = "${var.service_name}-csv-${var.environment}"
  logging_service_name  = "${var.service_name}-logit-${var.environment}"
  postgres_service_name = "${var.service_name}-postgres-${var.environment}"
  web_app_name          = "${var.service_name}-${var.environment}"
  worker_app_name       = "${var.service_name}-${var.environment}-worker"
}
