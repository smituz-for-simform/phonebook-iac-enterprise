# Service Plan

output "service_plan_id" {
  value = azurerm_service_plan.app_plan.id
}

output "service_plan_name" {
  value = azurerm_service_plan.app_plan.name
}


# Web App

output "web_app_id" {
  value = azurerm_linux_web_app.backend.id
}

output "web_app_name" {
  value = azurerm_linux_web_app.backend.name
}

output "default_hostname" {
  value = azurerm_linux_web_app.backend.default_hostname
}

output "backend_url" {
  value = "https://${azurerm_linux_web_app.backend.default_hostname}"
}


# Managed Identity

output "principal_id" {
  value = azurerm_linux_web_app.backend.identity[0].principal_id
}

output "tenant_id" {
  value = azurerm_linux_web_app.backend.identity[0].tenant_id
}