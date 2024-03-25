variable "resource_group_name" {
  description = "Name of resource group"
  type = string
  default = "CloudResumeChallenge"
}

variable "location" {
  description = "Azure region"
  type = string
  default = "southeastasia"
}

variable "storage_name" {
  description = "Name of storage account"
  type = string
  default = "rccstorage1"
}

variable "cosmosdb_name" {
  description = "Name of database"
  type = string
  default = "cosmosdbrcc"
}

variable "service_plan_name" {
  description = "Name of service plan"
  type = string
  default = "ASP-rcc-function-app-26c0"
}

variable "function_app_name" {
  description = "Name of function app"
  type = string
  default = "rcc-function-app"
}

variable "cdn_profile_name" {
  description = "Name of CDN profile"
  type = string
  default = "rcc-cdn-profile"
}

variable "cdn_endpoint_name" {
  description = "Name of CDN endpoint"
  type = string
  default = "mk-rcc-cdn-endpoint"
}

variable "key_vault_name" {
  description = "Name of CDN endpoint"
  type = string
  default = "rcc-key-vault"
}