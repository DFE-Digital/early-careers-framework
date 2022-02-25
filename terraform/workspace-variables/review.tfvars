# Platform
app_environment = "review"

# Gov.UK PaaS
paas_api_url = "https://api.london.cloud.service.gov.uk"
paas_space_name = "earlycareers-framework-dev"
paas_postgres_service_plan = "tiny-unencrypted-11"
paas_app_start_timeout = "240"
paas_app_stopped = false
paas_web_app_deployment_strategy = "blue-green-v2"
paas_web_app_instances = 1
paas_web_app_memory = 1024
paas_web_app_start_command = "bundle exec rake cf:on_first_instance db:migrate db:safe_reset redis:flushall && (bundle exec sidekiq -C config/sidekiq.yml &) && rails s"
paas_redis_service_plan = "micro-6_x"
