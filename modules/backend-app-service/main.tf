resource "azurerm_service_plan" "app_plan" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = "Linux"
  sku_name = var.service_plan_sku
}

resource "azurerm_linux_web_app" "backend" {

  name                = var.web_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id = azurerm_service_plan.app_plan.id

  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }

  site_config {

    always_on                         = true
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 10

    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"

   # vnet_route_all_enabled = true

    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = var.docker_registry_url
      docker_registry_username = var.docker_registry_username
      docker_registry_password = var.docker_registry_password
    }
  }

  app_settings = {

    WEBSITES_PORT = var.container_port
    PORT          = var.container_port

    ENV = "production"

    DB_HOST = var.db_host
    DB_PORT = var.db_port

    DB_NAME     = var.db_name_secret_uri
    DB_USER     = var.db_user_secret_uri
    DB_PASSWORD = var.db_password_secret_uri

    AZURE_STORAGE_ACCOUNT_NAME = var.storage_account_name
    AZURE_STORAGE_CONTAINER    = var.storage_container_name

    FRONTEND_URL = var.frontend_url
  }

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "backend" {

  app_service_id = azurerm_linux_web_app.backend.id
  subnet_id      = var.backend_subnet_id
}