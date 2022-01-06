resource cloudfoundry_service_instance postgres_instance {
  name = local.postgres_service_name
  space = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"
}

resource cloudfoundry_service_instance csv_bucket {
  name = local.csv_bucket_name
  space = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.aws-s3-bucket.service_plans["default"]
}

resource cloudfoundry_app web_app {
  name = local.web_app_name
  command = var.web_app_start_command
  docker_image = var.app_docker_image
  docker_credentials = var.docker_credentials
  health_check_type = "http"
  health_check_http_endpoint = "/check"
  health_check_timeout = 60
  instances = var.web_app_instances
  memory = var.web_app_memory

  space = data.cloudfoundry_space.space.id
  stopped = var.app_stopped
  strategy = var.web_app_deployment_strategy
  timeout = var.app_start_timeout

  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
  routes {
    route = cloudfoundry_route.web_app_route.id
  }
  dynamic "routes" {
    for_each = cloudfoundry_route.web_app_route_gov_uk
    content {
      route = routes.value["id"]
    }
  }
  environment = local.app_environment
}

resource cloudfoundry_route web_app_route {
  domain = data.cloudfoundry_domain.cloudapps_digital.id
  space = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource cloudfoundry_route web_app_route_gov_uk {
  for_each = toset(var.govuk_hostnames)
  domain = data.cloudfoundry_domain.education_gov_uk.id
  space = data.cloudfoundry_space.space.id
  hostname = each.value
}

resource "cloudfoundry_app" "sidekiq_worker_app" {
  name = local.sidekiq_worker_app_name
  command = var.sidekiq_worker_app_start_command
  docker_image = var.app_docker_image
  docker_credentials = var.docker_credentials
  health_check_type = "process"
  health_check_timeout = 10
  instances = var.sidekiq_worker_app_instances
  memory = var.sidekiq_worker_app_memory

  space = data.cloudfoundry_space.space.id
  stopped = var.app_stopped
  strategy = var.sidekiq_worker_app_deployment_strategy
  timeout = var.app_start_timeout
  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
  environment = local.app_environment
}

resource cloudfoundry_user_provided_service logging {
  name = local.logging_service_name
  space = data.cloudfoundry_space.space.id
  syslog_drain_url = var.logstash_url
}

resource cloudfoundry_service_instance worker_redis_instance {
  name         = local.redis_worker_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_service_plan]
  json_params  = jsonencode(local.noeviction_maxmemory_policy)
  timeouts {
    create = "30m"
  }
}
