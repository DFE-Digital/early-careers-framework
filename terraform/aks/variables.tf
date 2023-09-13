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

variable "db_sslmode" {
  default = "require"
}

variable "postgres_flexible_server_sku" {
  default = "B_Standard_B1ms"
}

variable "postgres_enable_high_availability" {
  default = false
}

variable "azure_enable_backup_storage" {
  default = false
}

variable "redis_queue_capacity" {
  default = 1
}

variable "redis_queue_family" {
  default = "C"
}

variable "redis_queue_sku_name" {
  default = "Standard"
}

variable "domain" {
  type = string
}
