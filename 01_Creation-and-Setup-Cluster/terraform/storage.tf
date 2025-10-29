resource "azurerm_storage_account" "files" {
  name                      = "myclusterfiles"
  resource_group_name       = data.azurerm_resource_group.existing.name
  location                  = data.azurerm_resource_group.existing.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_share" "fileshare" {
  name                 = "cluster-share"
  storage_account_id  = azurerm_storage_account.files.id
  quota                = 10 
}