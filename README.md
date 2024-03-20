# Deploying Microsoft Sentinel, Collecting Logs (Syslog & Diagnostic Settings), Creating/Modifying Analytics Rules and VMs Infrastructure as Code (IaC) Deployment with Terraform
![topologyterraf](https://github.com/t0neex/Power-Of-Terraform-On-Azure-and-MicrosoftSentinel/assets/100233276/db63bf29-f859-48c3-a825-5beda3a92510)

This repository contains a Terraform script for deploying and modifying resources on Azure. # This is related to the creation of Proof of Concepts (PoCs) for Microsoft Sentinel #. Here's a brief overview of what each block in the `main.tf` file does:

1. `provider "azurerm"`: Configures the Azure Resource Manager (ARM) provider.
2. `resource "azurerm_management_group"`: Creates an Azure Management Group.
3. `resource "azurerm_management_group_subscription_association"`: Associates a subscription with the management group.
4. `resource "azurerm_resource_group"`: Creates an Azure Resource Group.
5. `resource "azurerm_log_analytics_workspace"`: Creates a Log Analytics workspace.
6. `resource "azurerm_log_analytics_solution"`: Deploys a solution into the Log Analytics workspace.
7. `resource "azurerm_virtual_network"` and `resource "azurerm_subnet"`: Create a virtual network and a subnet within that network.
8. `resource "azurerm_network_interface"`: Creates a network interface.
9. `resource "azurerm_public_ip"`: Creates a public IP address.
10. `resource "azurerm_linux_virtual_machine"`: Creates a Linux virtual machine.
11. `resource "azurerm_monitor_data_collection_rule"`: Creates a data collection rule for Azure Monitor.
12. `resource "azurerm_virtual_machine_extension"`: Adds an extension to the virtual machine.
13. `resource "azurerm_monitor_data_collection_rule_association"`: Associates the data collection rule with the virtual machine.
14. `resource "azurerm_network_security_group"` and `resource "azurerm_network_security_rule"`: Create a network security group and a security rule within that group.
15. `resource "azurerm_network_interface_security_group_association"`: Associates the network security group with the network interface.
16. `resource "azurerm_monitor_aad_diagnostic_setting"`: Creates a diagnostic setting for Azure Active Directory / Entra ID. It installs Azure Activity Connector!
17. `resource "azurerm_sentinel_alert_rule_scheduled"`: Creates a scheduled alert rule in Azure Sentinel.

Please note that this is a high-level overview. Each block has many properties that can be configured based on your specific requirements. Also, the actual resources created and their configurations will depend on the values of the variables used in this script. And do not forget to check variables!

## Steps followed to Work with `main.tf`

1. **Define your provider**: Specify Azure as the provider in the `main.tf` and provide any necessary credentials.
2. **Configure your resources**: Define each resource that Terraform is to manage. This could be anything from virtual networks to application services.
3. **Set up resource dependencies**: If any resources depend on others (for example, a virtual machine depending on a virtual network), this needs to be expressed in the configuration.
4. **Plan your deployment**: Run the `terraform plan` command to ensure that the configuration is correct and that the desired resources will be created.
5. **Apply your configuration**: Use the `terraform apply` command to create the resources in Azure.
6. **Modify and update as needed**: As the project evolves, the `main.tf` file can be updated to manage additional resources or modify existing ones. After making changes, repeat the plan and apply steps.
7. **Destroy resources when done**: When the resources are no longer needed, use the `terraform destroy` command to remove them from Azure and clean up.

This project is a testament to the power of automation and the efficiency of Infrastructure as Code. It's a great example of how technology can be used to simplify complex tasks and improve productivity even for creating PoC's :)
