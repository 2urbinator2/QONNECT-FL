variable "vm_names" {
    type    = list(string)
    default = [
        "knowledge-base",
        "cloud-energy-control",
        "cloud-energy-worker",
        "fog-energy-control",
        "fog-energy-worker",
        "edge-energy-control",
        "edge-energy-worker"
    ]
}