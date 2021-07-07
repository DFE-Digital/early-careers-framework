# Platform
environment = "staging"
app_environment = "staging"

# Gov.UK PaaS
paas_api_url = "https://api.london.cloud.service.gov.uk"
paas_space_name = "early-careers-framework-staging"
paas_postgres_service_plan = "small-ha-11"
paas_app_start_timeout = "180"
paas_app_stopped = false
paas_web_app_deployment_strategy = "blue-green-v2"
paas_web_app_instances = 2
paas_web_app_memory = 8192
paas_worker_app_instances = 1
paas_worker_app_start_command = "/app/bin/delayed_job --pool=mailers --pool=*:2 start && bundle exec rake jobs:work"
govuk_hostnames = ["s-manage-training-for-early-career-teachers"]
