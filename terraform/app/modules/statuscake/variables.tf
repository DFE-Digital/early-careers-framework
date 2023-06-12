variable "environment" {
}

variable "service_name" {
}

variable "statuscake_alerts" {
  description = "Define Statuscake alerts with the attributes below"
}

variable "statuscake_domain" {
  type        = string
  description = "Domain for SSL check"
}

variable "statuscake_ssl_contact_group" {
  type        = string
  description = "ID of the StatusCake contact group. If empty, SSL check is not enabled"
}
