# "none" means tf could not register resources
# all resources are under a specific resource group

provider "azurerm" {
    resource_provider_registrations = "none"
    features {}
    subscription_id = var.subscription_id
}

data "azurerm_resource_group" "existing" {
  name = var.resource_group
}
