module "prometheus_all" {
  source = "git::https://github.com/ethanmills/cf-monitoring.git//prometheus_all"

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_org_name = "dfe"
  monitoring_space_name = var.paas_space_name
  paas_exporter_username = var.paas_user
  paas_exporter_password = var.paas_password
  alert_rules = file("${path.module}/config/${var.environment}/alert.rules.yml")
  alertmanager_slack_url = var.alertmanager_slack_url
  alertmanager_slack_channel = "cpd-dev-alerts"
  alertmanager_slack_template = file("${path.module}/config/")
  grafana_admin_password = var.grafana_admin_password
  grafana_google_client_id = var.google_client_id
  grafana_google_client_secret = var.google_client_secret
  grafana_runtime_version = "7.2.2"
}