# "none" means tf could not register resources
# all resources are under a specific resource group

provider "azurerm" {
    resource_provider_registrations = "none"
    features {}
    subscription_id = "3b7f0d07-2848-4c7c-87d3-074743ad0131"
}

data "azurerm_resource_group" "existing" {
  name = "FelixSwarmchestrate"
}
