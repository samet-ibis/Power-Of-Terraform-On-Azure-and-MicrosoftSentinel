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

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.sentinel_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface for VM
resource "azurerm_network_interface" "nic1" {
  name                = "example-nic1"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
     private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"  # Static IP for VM1
	public_ip_address_id          = azurerm_public_ip.vm1_public_ip.id  # Associate Public IP here
  }
}
resource "azurerm_public_ip" "vm1_public_ip" {
  name                = "example-vm1-public-ip"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Virtual Machine 1
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "example-vm1"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  disable_password_authentication = false
  admin_password                  = "@_str0ng_p@ssw0rd_1071!"
}

resource "azurerm_monitor_data_collection_rule" "syslog_dcr" {
  name                = "syslog-collection-rule"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name

  destinations {
    log_analytics {
      name                = "sentinel_laws_destination" 
      workspace_resource_id = azurerm_log_analytics_workspace.sentinel_laws.id
    }
  }

  data_flow {
    streams       = ["Microsoft-Syslog"]
    destinations  = ["sentinel_laws_destination"]
  }

  data_sources {
    syslog {
      name         = "syslog" # This name identifies this syslog configuration within the DCR
      log_levels   = ["Error", "Warning", "Info"] 
      facility_names = ["*"] # Collects logs from all facilities
    }
  }
}

resource "azurerm_virtual_machine_extension" "ama_linux" {
  name                   = "AzureMonitorLinuxAgent"
  virtual_machine_id     = azurerm_linux_virtual_machine.vm1.id
  publisher              = "Microsoft.Azure.Monitor"
  type                   = "AzureMonitorLinuxAgent"
  type_handler_version   = "1.0"
  auto_upgrade_minor_version = true
  settings               = "{}"
}

resource "azurerm_monitor_data_collection_rule_association" "dcr_association" {
  name                    = "DCR-VM-Association"
  target_resource_id      = azurerm_linux_virtual_machine.vm1.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.syslog_dcr.id
  description             = "Association between the Data Collection Rule and the Linux VM."
}

resource "azurerm_network_security_group" "example_nsg" {
  name                = "example-vm1-nsg"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
}
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sentinel_rg.name
  network_security_group_name = azurerm_network_security_group.example_nsg.name
}

resource "azurerm_network_interface_security_group_association" "nic1nsg" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}
resource "azurerm_monitor_aad_diagnostic_setting" "example" {
  name                   = "activity-logs-diag-settings"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel_laws.id

  enabled_log {
    category = "AuditLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
     enabled = false
    }
  }
  enabled_log {
    category = "ServicePrincipalSignInLogs"
    retention_policy {
     enabled = false
    }
  }
   enabled_log {
    category = "SignInLogs"
    retention_policy {
     enabled = false
    }
  }

  # Add more log categories as needed
}

resource "azurerm_sentinel_alert_rule_scheduled" "failed_ssh_rule" {
  name                  = "Failed SSH Login"
  display_name          = "Failed SSH Login Detection Rule" 
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel_laws.id
  query                 = "Syslog | where SyslogMessage contains \"Failed Password\" | order by EventTime desc"
  severity              = "High"
  query_frequency	= "PT5M"
  query_period	= "PT5M"
}