variable "environment" {
  description = "Current Environment of the Project"
  type        = string
}

variable "location" {
  description = "Locatio for resources in the env"
  type        = string
}

# Network Foundation

variable "vnet-addr-space" {
  description = "Address space for the Vnet"
  type        = list(string)
}


# DB Postgresql Server
variable "db_password" {
  description = "Admin Password for postgres server"
  type        = string
  sensitive   = true
}

variable "db_name_secret_uri" {
  description = "DB NameSecret URI from Key Vault"
  type        = string
  sensitive   = true
}

variable "db_password_secret_uri" {
  description = "DB Password Secret URI from Key Vault"
  type        = string
  sensitive   = true
}

# Backend App Service

variable "docker_registry_username" {
  description = "Username for Docker registry"
  type        = string
}

variable "docker_registry_password" {
  description = "Password for Docker registry"
  type        = string
  sensitive   = true
}

# Frontend

variable "vm_size" {
  description = "Size of Frontend VM"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "security_rules_frontend" {
  description = "NSG rules for frontend VM"
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))

  default = {
    "AllowHttp" = {
      name                       = "AllowHttp"
      priority                   = "101"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}