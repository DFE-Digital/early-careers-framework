variable environment {}


# Gov.UK PaaS
variable paas_api_url {
}

variable paas_password {
  default = ""
}

variable paas_app_docker_image {
  default = ""
}

variable paas_app_start_timeout {
  default = 300
}

variable paas_app_stopped {
  default = false
}

variable app_environment {
  default = "dev"
}

variable paas_postgres_service_plan {
  default = "tiny-unencrypted-11"
}

variable paas_redis_service_plan {
  default = "tiny-4_x"
}

variable paas_space_name {
}

variable paas_sso_passcode {
  default = ""
}

variable paas_store_tokens_path {
  default = ""
}

variable paas_user {
  default = ""
}

variable paas_web_app_deployment_strategy {
  default = "blue-green-v2"
}

variable paas_web_app_instances {
  default = 1
}

variable paas_web_app_memory {
  default = 512
}

variable paas_web_app_start_command {
  default = "bundle exec rake cf:on_first_instance db:migrate && rails s"
}

variable paas_worker_app_deployment_strategy {
  default = "blue-green-v2"
}

variable paas_worker_app_instances {
  default = 1
}

variable paas_worker_app_memory {
  default = 512
}

variable logstash_url {
  default = ""
}

variable secret_paas_app_env_values {
  default = {}
  type = map(string)
}

locals {
  paas_app_env_yml_values = yamldecode(file("${path.module}/../workspace-variables/${var.app_environment}_app_env.yml"))
  paas_app_env_values = merge(
    local.paas_app_env_yml_values,
    var.secret_paas_app_env_values
  )
  is_production = var.environment == "production"
  service_name = "ecf"
}
