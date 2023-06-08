resource "statuscake_uptime_check" "alert" {
  for_each       = var.statuscake_alerts

  name           = each.value.website_name
  contact_groups = each.value.contact_group
  confirmation   = 1
  trigger_rate   = 0
  check_interval = 30
  regions        = ["london", "dublin"]

  http_check {
    follow_redirects = true
    timeout          = 40
    request_method   = "HTTP"
    status_codes     = ["204", "205", "206", "303", "400", "401", "403", "404", "405", "406", "408", "410", "413", "444", "429", "494", "495", "496", "499", "500", "501", "502", "503", "504", "505", "506", "507", "508", "509", "510", "511", "521", "522", "523", "524", "520", "598", "599"]
    validate_ssl     = false
  }

  monitored_resource {
    address = each.value.website_url
  }
}

resource "statuscake_ssl_check" "domain-alert" {
  count = var.statuscake_ssl_contact_group != null ? 1 : 0

  check_interval   = 3600 # Check once per hour
  contact_groups   = [var.statuscake_ssl_contact_group]
  follow_redirects = true

  alert_config {
    alert_at = [3, 7, 30] # Alert 1 month, 1 week then 3 days before expiration

    on_reminder = true
    on_expiry   = true
    on_broken   = true
    on_mixed    = true
  }

  monitored_resource {
    address = "https://${var.domain}"
  }
}
