variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

# variable "environment" {
#   type = string
# }


# Networking

variable "backend_subnet_id" {
  type = string
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}


# Service Plan

variable "service_plan_name" {
  type = string
}

variable "service_plan_sku" {
  type    = string
  default = "B1"
}


# Web App

variable "web_app_name" {
  type = string
}

variable "container_port" {
  type    = string
  default = "8080"
}

variable "health_check_path" {
  type    = string
  default = "/api/health"
}


# Docker

variable "docker_image_name" {
  type = string
}

variable "docker_registry_url" {
  type    = string
  default = "https://index.docker.io"
}

variable "docker_registry_username" {
  type      = string
  sensitive = true
}

variable "docker_registry_password" {
  type      = string
  sensitive = true
}


# Database

variable "db_host" {
  type = string
}

variable "db_port" {
  type    = string
  default = "5432"
}


# Key Vault References


variable "db_name_secret_uri" {
  type = string
}

variable "db_user_secret_uri" {
  type = string
}

variable "db_password_secret_uri" {
  type = string
}


# Storage

variable "storage_account_name" {
  type = string
}

variable "storage_container_name" {
  type = string
}


# Frontend

variable "frontend_url" {
  type    = string
  default = "*"
}