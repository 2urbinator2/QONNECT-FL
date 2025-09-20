variable "vm_names" {
    type    = list(string)
    default = [
        "cloud-performance-control",
        "cloud-performance-worker",
        "fog-energy-control",
        "fog-energy-worker",
        "edge-energy-control",
        "edge-energy-worker",
        "knowledge-base"
    ]
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