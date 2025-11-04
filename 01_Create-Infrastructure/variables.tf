variable "vm_names" {
  type = list(string)
  default = [
    # Energy 
    "cloud-energy-control",
    "cloud-energy-worker", 
    "edge-energy-control",
    "edge-energy-worker", 
    #"fog-energy-control",
    #"fog-energy-worker", 
    # Performance 
    #"cloud-performance-control",
    #"cloud-performance-worker", 
    # Cost
    #"cloud-cost-control",
    #"cloud-cost-worker", 
    # Mangement VM  
    "central-management-vm"       
  ]
}

variable "vm_sizes" {
  type = map(string)
  default = {
    # Energy
    "cloud-energy-control"        = "Standard_B2ps_v2"
    "cloud-energy-worker"         = "Standard_B2ps_v2"
    "edge-energy-control"         = "Standard_B2pls_v2" 
    "edge-energy-worker"          = "Standard_B2pls_v2"  
    #"fog-energy-control"         = "Standard_B2pls_v2" 
    #"fog-energy-worker"          = "Standard_B2pls_v2"
    # Performance
    #"cloud-performance-control"  = "Standard_B2pls_v2" 
    #"cloud-performance-worker"   = "Standard_B2pls_v2" 
    # Cost
    #"cloud-cost-control"         = "Standard_B2pls_v2" 
    #"cloud-cost-worker"          = "Standard_B2pls_v2"
    # Management VM  
    "central-management-vm"       = "Standard_B2pls_v2"
  }
}

variable "my_ip" {
  description = "IP of the host"
  type        = string
}

variable "admin_username" {
  description = "Username of the instance user"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key"
  type        = string
  default     = "~/.ssh/az-key.pub"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group" {
  description = "Name for Azure Resource Group"
  type        = string
}