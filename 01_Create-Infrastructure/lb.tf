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
  ip_address                = "10.0.1.6"  
}

# Cloud-Energy-Worker
resource "azurerm_lb_backend_address_pool_address" "cloud-energy-worker" {
  name                      = "cloud-energy-worker"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.backendpool.id
  virtual_network_id        = azurerm_virtual_network.vnet.id
  ip_address                = "10.0.1.7"   
}

# Cloud-Cost-Control 
resource "azurerm_lb_backend_address_pool_address" "cloud-cost-control" {
  name                      = "cloud-cost-control"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.backendpool.id
  virtual_network_id        = azurerm_virtual_network.vnet.id
  ip_address                = "10.0.1.4"  
}

# Cloud-Cost-Worker
resource "azurerm_lb_backend_address_pool_address" "cloud-cost-worker" {
  name                      = "cloud-cost-worker"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.backendpool.id
  virtual_network_id        = azurerm_virtual_network.vnet.id
  ip_address                = "10.0.1.10"   
}


# Health Probe für Port 8080
resource "azurerm_lb_probe" "probe_8080" {
  name                = "tcp-probe-8080"
  loadbalancer_id     = azurerm_lb.metalb_lb.id
  protocol            = "Tcp"
  port                = 8080
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Health Probe für Port 8081
resource "azurerm_lb_probe" "probe_8081" {
  name                = "tcp-probe-8081"
  loadbalancer_id     = azurerm_lb.metalb_lb.id
  protocol            = "Tcp"
  port                = 8081
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Health Probe für Port 443
resource "azurerm_lb_probe" "probe_443" {
  name                = "tcp-probe-443"
  loadbalancer_id     = azurerm_lb.metalb_lb.id
  protocol            = "Tcp"
  port                = 443
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Health Probe für Port 80
resource "azurerm_lb_probe" "probe_80" {
  name                = "tcp-probe-80"
  loadbalancer_id     = azurerm_lb.metalb_lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

# LB Rule für Port 8080
resource "azurerm_lb_rule" "rule_8080" {
  name                           = "lb-rule-8080"
  loadbalancer_id                = azurerm_lb.metalb_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backendpool.id]
  probe_id                       = azurerm_lb_probe.probe_8080.id
}

# LB Rule für Port 8081
resource "azurerm_lb_rule" "rule_8081" {
  name                           = "lb-rule-8081"
  loadbalancer_id                = azurerm_lb.metalb_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 8081
  backend_port                   = 8081
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backendpool.id]
  probe_id                       = azurerm_lb_probe.probe_8081.id
}

# LB Rule für Port 443
resource "azurerm_lb_rule" "rule_443" {
  name                           = "lb-rule-443"
  loadbalancer_id                = azurerm_lb.metalb_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backendpool.id]
  probe_id                       = azurerm_lb_probe.probe_443.id
}

# LB Rule für Port 80
resource "azurerm_lb_rule" "rule_80" {
  name                           = "lb-rule-80"
  loadbalancer_id                = azurerm_lb.metalb_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backendpool.id]
  probe_id                       = azurerm_lb_probe.probe_80.id
}