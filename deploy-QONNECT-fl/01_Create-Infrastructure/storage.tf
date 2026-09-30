resource "azurerm_managed_disk" "rla_storage" {
  count                = 2
  name                 = "rla-disk-${count.index}"
  location             = data.azurerm_resource_group.existing.location   
  resource_group_name  = data.azurerm_resource_group.existing.name
  storage_account_type = "Premium_LRS"       
  create_option        = "Empty"
  disk_size_gb         = 4                    
}