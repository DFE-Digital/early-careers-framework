resource cloudfoundry_service_instance postgres_instance {
  name = local.postgres_service_name
  space = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"
}

resource cloudfoundry_app web_app {
  name = local.web_app_name
  command = var.web_app_start_command
  docker_image = var.app_docker_image
  health_check_type = "http"
  health_check_http_endpoint = "/check"
  instances = var.web_app_instances
  memory = var.web_app_memory

  space = data.cloudfoundry_space.space.id
  stopped = var.app_stopped
  strategy = var.web_app_deployment_strategy
  timeout = var.app_start_timeout

  service_binding {
    service_instance = cloudfoundry_user_provided_service.logging.id
  }

  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
  routes {
    route = cloudfoundry_route.web_app_route.id
  }
  environment = local.app_environment
}

resource cloudfoundry_route web_app_route {
  domain   = data.cloudfoundry_domain.cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource cloudfoundry_user_provided_service logging {
  name             = local.logging_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.logstash_url
}
