provider "azurerm" {
    resource_provider_registrations = "none"
    features {}
    subscription_id = var.subscription_id
}

data "azurerm_resource_group" "existing" {
  name = var.resource_group
}
