variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "db_subnet_id" {
  type = string 
}

variable "server_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "postgres_version" {
  type    = string
  default = "17"
}

variable "zone" {
  type    = string
  default = "1"
}

variable "sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "storage_mb" {
  type    = number
  default = 32768
}

variable "storage_tier" {
  type    = string
  default = "P4"
}

variable "private_dns_zone_name" {
  type    = string
  default = "db-phonebook.postgres.database.azure.com"
}

variable "private_dns_zone_link_name" {
  type    = string
  default = "attach-phonebook-vnet"
}

variable "storage_account_name" {
  type = string
}

variable "storage_container_name" {
  type    = string
  default = "uploads"
}