# Load Balncer 
resource "azurerm_lb" "metalb_lb" {
  name                = "metalb-frontend-lb"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.50"
  }
}

# Backend-Pool für Load Balancer
resource "azurerm_lb_backend_address_pool" "backendpool" {
  loadbalancer_id = azurerm_lb.metalb_lb.id
  name            = "backendpool"
}

# Cloud-Energy-Control
resource "azurerm_lb_backend_address_pool_address" "cloud-energy-control" {
  name                      = "cloud-energy-control"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.backendpool.id
  virtual_network_id        = azurerm_virtual_network.vnet.id
  ip_address                = "10.0.1.6"   # IP des ersten Worker-Nodes
}

# Cloud-Energy-Worker
resource "azurerm_lb_backend_address_pool_address" "cloud-energy-worker" {
  name                      = "cloud-energy-worker"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.backendpool.id
  virtual_network_id        = azurerm_virtual_network.vnet.id
  ip_address                = "10.0.1.7"   # IP des ersten Worker-Nodes
}

# Edge-Energy-Control 
resource "azurerm_lb_backend_address_pool_address" "edge-energy-control" {
  name                      = "edge-energy-control"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.backendpool.id
  virtual_network_id        = azurerm_virtual_network.vnet.id
  ip_address                = "10.0.1.8"  
}

# Edge-Energy-Worker
resource "azurerm_lb_backend_address_pool_address" "edge-energy-worker" {
  name                      = "edge-energy-worker"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.backendpool.id
  virtual_network_id        = azurerm_virtual_network.vnet.id
  ip_address                = "10.0.1.4"   
}



resource "azurerm_lb_probe" "probe" {
  resource_group_name = data.azurerm_resource_group.existing.name
  loadbalancer_id     = azurerm_lb.metalb_lb.id
  name                = "tcp-probe-8080"
  protocol            = "Tcp"
  port                = 8080 
  interval_in_seconds = 5
  number_of_probes    = 2
}