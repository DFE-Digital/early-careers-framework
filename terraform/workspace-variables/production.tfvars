# Platform
environment = "production"
app_environment = "production"

# Gov.UK PaaS
paas_api_url = "https://api.london.cloud.service.gov.uk"
paas_space_name = "early-careers-framework-prod"
paas_postgres_service_plan = "small-11"
paas_app_start_timeout = "180"
paas_app_stopped = false
paas_web_app_deployment_strategy = "standard"
paas_web_app_instances = 1
paas_web_app_memory = 8192
govuk_hostnames = ["manage-training-for-early-career-teachers"]
statuscake_alerts = {
  "prod" = {
    website_name  = "manage-training-for-early-career-teachers-production"
    website_url   = "https://manage-training-for-early-career-teachers.education.gov.uk/check"
    contact_group = [206487]
  }
  "stringmatch" = {
    website_name  = "manage-training-for-early-career-teachers-production"
    website_url   = "https://manage-training-for-early-career-teachers.education.gov.uk"
    contact_group = [206487]
    find_string   = "Manage training for early career teachers"
  }
  "PaaS500String" = {
    website_name  = "manage-training-for-early-career-teachers-production"
    website_url   = "https://manage-training-for-early-career-teachers.education.gov.uk"
    contact_group = [206487]
    find_string   = "500 Internal Server Error"
    do_not_find   = true
  }
}