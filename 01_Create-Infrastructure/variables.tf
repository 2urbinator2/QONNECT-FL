variable "vm_names" {
    type    = list(string)
    default = [
        "cloud-energy-master",
        "cloud-energy-worker",
        "knowledge-base",
        "fog-energy-worker",
        "fog-energy-master",
        "edge-energy-master",
        "edge-energy-worker"
    ]
}