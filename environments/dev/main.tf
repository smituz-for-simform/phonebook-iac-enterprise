resource "azurerm_resource_group" "rg" {
  name     = "rg-phonebook-${var.environment}"
  location = var.location

}

# Network Foundation
module "network" {
  source           = "Azure/avm-res-network-virtualnetwork/azurerm"
  version          = "0.17.1"
  enable_telemetry = false

  name          = "vnet-phonebook-${var.environment}"
  location      = azurerm_resource_group.rg.location
  address_space = var.vnet-addr-space
  parent_id     = azurerm_resource_group.rg.id

  subnets = {
    db = {
      name           = "snet-phonebook-${var.environment}-db"
      address_prefix = cidrsubnet(var.vnet-addr-space[0], 8, 0)

      service_endpoints_with_location = [
        {
          service = "Microsoft.Storage"
        }
      ]

      delegations = [
        {
          name = "fs"

          service_delegation = {
            name = "Microsoft.DBforPostgreSQL/flexibleServers"
          }
        }
      ]
    }

    backend = {
      name           = "snet-phonebook-${var.environment}-backend"
      address_prefix = cidrsubnet(var.vnet-addr-space[0], 8, 1)

      delegations = [
        {
          name = "appservice"

          service_delegation = {
            name = "Microsoft.Web/serverFarms"
          }
        }
      ]
    }

    frontend = {
      name           = "snet-phonebook-${var.environment}-frontend"
      address_prefix = cidrsubnet(var.vnet-addr-space[0], 8, 2)
    }
  }
}



# Database

module "db" {
  source = "../../modules/db-postgresql-server"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  vnet_id      = module.network.resource_id
  db_subnet_id = module.network.subnets.db.resource_id

  server_name    = "phonebook-${var.environment}-db-psql-server"
  database_name  = "db-phonebook"
  admin_username = "dbadminphonebook"
  admin_password = var.db_password

  storage_account_name   = "saphonebookimages${var.environment}"
  storage_container_name = "uploads"

  depends_on = [module.network]
}

# Backend

module "backend" {
  source = "../../modules/backend-app-service"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_sku    = "B1"

  # environment = var.environment

  backend_subnet_id = module.network.subnets.backend.resource_id

  service_plan_name        = "phonebook-non-prod-service-plan"
  web_app_name             = "wa-phonebook-${var.environment}-backend"
  docker_image_name        = "smituzsimform/phonebook-smituz:cloud-ready-backend-v5"
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password

  db_host = module.db.postgres_fqdn

  db_name_secret_uri = "@Microsoft.KeyVault(SecretUri=${var.db_name_secret_uri})"
  db_user_secret_uri = module.db.admin_username
  #db_user_secret_uri     = "@Microsoft.KeyVault(SecretUri=${var.db_user_secret_uri})"
  db_password_secret_uri = "@Microsoft.KeyVault(SecretUri=${var.db_password_secret_uri})"

  storage_account_name   = module.db.storage_account_name
  storage_container_name = module.db.storage_container_name

  depends_on = [module.db]
}


# Role Assignments

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.backend.principal_id
}

resource "azurerm_role_assignment" "blob_access" {
  scope                = module.db.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.backend.principal_id
}

# Frontend

module "frontend" {
  source              = "../../modules/frontend-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  frontend_subnet_id = module.network.subnets.frontend.resource_id

  vm_name = "vm-phonebook-${var.environment}-frontend"

  vm_size = var.vm_size

  admin_username = "azureuser-phonebook-${var.environment}"

  ssh_public_key = data.azurerm_key_vault_secret.ssh_public_key.value

  public_ip_name        = "pip-phonebook-${var.environment}-frontend"
  nic_name              = "nic-vm-${var.environment}"
  ip_configuration_name = "ip-config-vm-${var.environment}"
  nsg_name              = "nsg-vm-${var.environment}"

  os_disk_name = "os-disk-vm-${var.environment}"

  security_rules = var.security_rules_frontend

  depends_on = [module.backend]

} 

resource "azurerm_log_analytics_workspace" "law" {
  name = "law-phonebook"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


}
resource "azurerm_monitor_diagnostic_setting" "db-diagnostic" {
  name = "ds-phonebook-${var.environment}-db"
  target_resource_id = module.db.postgres_server_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "PostgreSQLLogs"
    }

 enabled_metric {
   category = "AllMetrics"
 }
}

resource "azurerm_monitor_diagnostic_setting" "sa-diagnostic" {
  name = "ds-phonebook-${var.environment}-storage"
  target_resource_id = module.db.storage_account_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_metric {
    category = "Capacity"
  }

  enabled_metric {
    category = "Transaction"
  }

}

resource "azurerm_monitor_diagnostic_setting" "container-diagnostic" {
  name = "ds-phonebook-${var.environment}-storage-container"
  target_resource_id =  "${module.db.storage_account_id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {category = "StorageRead"}
  enabled_log {category = "StorageWrite"}
  enabled_log {category = "StorageDelete"}
  enabled_metric {category = "Transaction"}

}

resource "azurerm_monitor_diagnostic_setting" "app-service-diagnostic" {
  name = "ds-phonebook-${var.environment}-backend"
  target_resource_id = module.backend.web_app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }

}

resource "azurerm_monitor_action_group" "ag" {
  name = "ag-phonebook-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  short_name = "phonebook"

  email_receiver {
    name = "Smit Bhansali"
    email_address = "smit.bhansali@simformsolutions.com"
    }
}

resource "azurerm_monitor_metric_alert" "backend_http_5xx" {
  name                = "alert-backend-http-5xx"
  resource_group_name = azurerm_resource_group.rg.name

  scopes = [
    module.backend.web_app_id
  ]

  description = "Backend HTTP 5xx error count is high"

  severity    = 2
  frequency   = "PT5M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"

    metric_name = "Http5xx"

    # Total aggregates the sum of all 5xx errors during the window
    aggregation = "Total"

    operator  = "GreaterThan"
    # Adjust this threshold based on your acceptable error tolerance
    threshold = 2
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}
