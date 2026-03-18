locals {
  external_url = var.external_hostname != null ? "https://${var.external_hostname}" : null
}

module "statuscake" {
  count = var.enable_monitoring ? 1 : 0

  source = "git::https://github.com/DFE-Digital/terraform-modules.git//monitoring/statuscake?ref=stable"

  uptime_urls = compact([module.web_application.probe_url, local.external_url])
  ssl_urls    = compact([local.external_url])

  contact_groups = [291418, 282453]
}
