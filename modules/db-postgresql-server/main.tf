resource "azurerm_private_dns_zone" "db_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
  name                  = var.private_dns_zone_link_name
  private_dns_zone_name = azurerm_private_dns_zone.db_dns.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "db_server" {

  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  version = var.postgres_version

  delegated_subnet_id = var.db_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.db_dns.id

  public_network_access_enabled = false

  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  zone = var.zone

  storage_mb   = var.storage_mb
  storage_tier = var.storage_tier

  sku_name = var.sku_name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.dns_vnet_link
  ]

  lifecycle {
    ignore_changes = [
      administrator_password
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "database" {

  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.db_server.id

  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_storage_account" "images" {

  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = true
}

resource "azurerm_storage_container" "images" {

  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.images.id
  container_access_type = "blob"
}