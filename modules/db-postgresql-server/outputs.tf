# PostgreSQL

output "postgres_server_id" {
  value = azurerm_postgresql_flexible_server.db_server.id
}

output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.db_server.name
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.db_server.fqdn
}

output "database_name" {
  value = azurerm_postgresql_flexible_server_database.database.name
}

output "admin_username" {
  value = azurerm_postgresql_flexible_server.db_server.administrator_login 
}


# DNS

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.db_dns.id
}

output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.db_dns.name
}


# Storage

output "storage_account_id" {
  value = azurerm_storage_account.images.id
}

output "storage_account_name" {
  value = azurerm_storage_account.images.name
}

output "storage_account_primary_blob_endpoint" {
  value = azurerm_storage_account.images.primary_blob_endpoint
}

output "storage_container_id" {
  value = azurerm_storage_container.images.id
}

output "storage_container_name" {
  value = azurerm_storage_container.images.name
}