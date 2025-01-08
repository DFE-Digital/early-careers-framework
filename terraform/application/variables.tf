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

variable "deploy_snapshot_database" {
  type    = string
  default = false
}

variable "azure_maintenance_window" {
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = null
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

variable "postgres_snapshot_flexible_server_sku" {
  default = "GP_Standard_D4ds_v4"
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

variable "redis_cache_capacity" {
  default = 1
}

variable "redis_cache_family" {
  default = "C"
}

variable "redis_cache_sku_name" {
  default = "Standard"
}

variable "domain" {
  type = string
  default = ""
}

variable "external_hostname" {
  type    = string
  default = null
}

variable "statuscake_api_token" {
}

variable "webapp_replicas" {
  default = 1
}

variable "worker_replicas" {
  default = 1
}

variable "webapp_memory_max" {
  type    = string
  default = "1Gi"
}

variable "worker_memory_max" {
  type    = string
  default = "1Gi"
}

variable "azure_storage_mb" {
  type    = number
  default = 32768
}

variable "azure_cpu_threshold" {
  type    = number
  default = 60
}

variable "enable_logit" { default = false }

variable "send_traffic_to_maintenance_page" {
  default     = false
  description = "During a maintenance operation, keep sending traffic to the maintenance page instead of resetting the ingress"
}

variable "enable_dfe_analytics_federated_auth" {
  description = "Create the resources in Google cloud for federated authentication and enable in application"
  default     = false
}

variable "dataset_name" {
  description = "dfe analytics dataset name in Google Bigquery"
  default     = null
}
