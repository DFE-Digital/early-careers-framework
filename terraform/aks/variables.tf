variable "app_environment" {
  type = string
}

variable "app_suffix" {
  type    = string
  default = ""
}

variable "namespace" {
  type = string
}

variable "cluster" {
  type = string
}

variable "deploy_azure_backing_services" {
  type    = string
  default = true
}

variable "azure_sp_credentials_json" {
  type    = string
  default = null
}

variable "docker_image" {
  type = string
}

variable "config_short" {
  type = string
}

variable "service_short" {
  type = string
}

variable "azure_resource_prefix" {
  type = string
}

variable "enable_monitoring" {
  type    = bool
  default = true
}
