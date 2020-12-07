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
  default = 1
}

variable web_app_memory {
  default = 512
}

variable web_app_start_command {
}

locals {

  app_env_domain  = { "DOMAIN" = "ecf-${var.environment}.london.cloudapps.digital" }
  app_environment = merge(
    local.app_env_domain,
    var.app_env_values #Because of merge order, if present, the value of DOMAIN in .tfvars will overwrite app_env_domain
  )
  app_cloudfoundry_service_instances = [
    cloudfoundry_service_instance.postgres_instance.id,
  ]
  app_service_bindings = concat(
    local.app_cloudfoundry_service_instances,
  )
  postgres_service_name    = "${var.service_name}-postgres-${var.environment}"
  web_app_name             = "${var.service_name}-${var.environment}"
}
