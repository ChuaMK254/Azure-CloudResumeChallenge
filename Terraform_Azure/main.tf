# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage account
resource "azurerm_storage_account" "sa" {
  name = var.storage_name
  location = var.location
  resource_group_name = var.resource_group_name
  account_tier = "Standard"
  account_kind = "StorageV2"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = "false"
  enable_https_traffic_only = "false"
  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
  cross_tenant_replication_enabled = "false"

  timeouts {}
}


resource "azurerm_cosmosdb_account" "cdb" {
  name = var.cosmosdb_name
  resource_group_name = var.resource_group_name
  location = var.location
  offer_type = "Standard"
  consistency_policy {
    consistency_level = "BoundedStaleness"
    max_interval_in_seconds = "86400"
    max_staleness_prefix = "1000000"
  }
  geo_location {
    location = var.location
    failover_priority = 0
  }
  tags = {
    defaultExperience = "Azure Table"
    hidden-cosmos-mmspecial = ""
  }

  timeouts {}
}

resource "azurerm_service_plan" "sp" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

# Secret in keyvault to get cosmosdb connection string
data "azurerm_key_vault_secret" "cs" {
  name         = "cosmos-db-connection-string"
  key_vault_id = resource.azurerm_key_vault.kv.id
}

resource "azurerm_linux_function_app" "fa" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = var.storage_name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.sp.id

  builtin_logging_enabled = "false"
  client_certificate_mode = "Required"

  site_config {
    ftps_state = "FtpsOnly"

    application_stack  {
      python_version = "3.11"
      # use_custom_runtime = "false"
      # use_dotnet_isolated_runtime = "false"
    }

    cors {
      allowed_origins = [
        "http://cmkand.me", "http://www.cmkand.me", "https://cmkand.me", "https://www.cmkand.me",
      ]
      support_credentials = "false"
    }
  }

  app_settings = {
    "CosmosDbString" = data.azurerm_key_vault_secret.cs.value
  }

  timeouts {}
}

resource "azurerm_dns_zone" "dz" {
  name                = "cmkand.me"
  resource_group_name = var.resource_group_name
}


resource "azurerm_cdn_profile" "cdn" {
  name                = var.cdn_profile_name
  location            = "Global"
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Microsoft"
  tags = {}
}

resource "azurerm_cdn_endpoint" "ep" {
  name                = var.cdn_endpoint_name
  profile_name        = azurerm_cdn_profile.cdn.name
  location            = "Global"
  resource_group_name = var.resource_group_name
  is_compression_enabled = "true"
  optimization_type = "GeneralWebDelivery"
  origin_host_header = "rccstorage1.z23.web.core.windows.net"

  origin {
    name      = "rccstorage1-z23-web-core-windows-net"
    host_name = "rccstorage1.z23.web.core.windows.net"
  }
}

