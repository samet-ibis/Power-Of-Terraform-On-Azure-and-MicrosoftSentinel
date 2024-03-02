provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "example_mgmt_group" {
  name         = var.management_group_name
  display_name = var.management_group_display_name
}

resource "azurerm_management_group_subscription_association" "example_association" {
  management_group_id = azurerm_management_group.example_mgmt_group.id
  subscription_id     = var.subscription_id
}

resource "azurerm_resource_group" "sentinel_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "sentinel_laws" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "sentinel_solution" {
  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.sentinel_rg.location
  resource_group_name   = azurerm_resource_group.sentinel_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.sentinel_laws.id
  workspace_name        = azurerm_log_analytics_workspace.sentinel_laws.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}
