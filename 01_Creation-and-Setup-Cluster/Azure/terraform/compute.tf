# the ip adresses are static and sku standard means that no external traffic is allowed
resource "azurerm_public_ip" "public_ip" {
  for_each            = toset(var.vm_names)
  name                = "${each.value}-pip"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Allows the VM to communicate from the subnet
resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.vm_names)
  name                = "${each.value}-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vms" {
    for_each = toset(var.vm_names)

    name                = each.value
    resource_group_name = data.azurerm_resource_group.existing.name
    location            = data.azurerm_resource_group.existing.location
    size                = "Standard_B2s"
    admin_username      = var.admin_username

    network_interface_ids = [azurerm_network_interface.nic[each.key].id]

    admin_ssh_key {
        username   = var.admin_username
        public_key = file(var.public_key_path)
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
    }
}