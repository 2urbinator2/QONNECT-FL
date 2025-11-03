# many resources are in virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-swarmchestrate"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
}

# to communicate along another resources are in a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-cluster"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# nsgs for only traffic from inside to outside possible and only specific IPs have access to the subnet 
resource "azurerm_network_security_group" "nsg" {
  name                = "specific-nsgs"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "AllowPostgresFromMyIP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "5432"
    source_address_prefix       = var.my_ip
    destination_address_prefix  = "*"
  }

  security_rule {
    name                       = "AllowPostgresFromVNet"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "5432"
    source_address_prefix       = "VirtualNetwork" 
    destination_address_prefix  = "*"
  }

  security_rule {
    name                       = "AllowPgAdminFromMyIP"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "5050"
    source_address_prefix       = var.my_ip
    destination_address_prefix  = "*"
  }

  security_rule {
    name                       = "AllowKubeAPI"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSMBOutbound"
    priority                   = 150
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "445"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    description                = "Allow outbound SMB (TCP 445) to Azure File Share"
  }

  security_rule {
    name                       = "FlowerConnection"
    priority                   = 160
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9093"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

}

# applies the rule to the subnet
resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
