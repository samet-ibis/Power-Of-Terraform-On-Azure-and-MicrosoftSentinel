variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the resource group"
  default     = "East US"

 validation {
    condition     = contains(["East US", "West US", "Central US", "North Europe", "West Europe", "Southeast Asia", "Australia East", "Japan East"], var.location)
    error_message = "The location must be one of the specified Azure regions: East US, West US, Central US, North Europe, West Europe, Southeast Asia, Australia East, Japan East."
  }
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of the Log Analytics workspace"
}

variable "management_group_name" {
  description = "The name of the management group."
  type        = string
}

variable "management_group_display_name" {
  description = "The display name of the management group."
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID to associate with the management group."
  type        = string
}