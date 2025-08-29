#!/bin/bash
# vagrant_vm_info.sh - Zeigt Port und NAT-IP für mehrere Vagrant-VMs

VMS=(
    "Cloud-Energy-Control"
    "Cloud-Energy-Worker"
    "Edge-Energy-Control"
    "Edge-Energy-Worker"
)

echo "VM Information (Port | NAT-IP enp0s9)"
echo "------------------------------------"

for VM in "${VMS[@]}"; do
    # Port aus ssh-config auslesen
    PORT=$(vagrant ssh-config "$VM" 2>/dev/null | awk '/Port/ {print $2}')
    
    # NAT-IP auslesen, fallback auf eth1 wenn enp0s9 fehlt
    IP=$(vagrant ssh "$VM" -c "ip -4 addr show dev enp0s9 2>/dev/null || ip -4 addr show dev eth1" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)
    
    if [[ -z "$IP" ]]; then
        IP="nicht gefunden"
    fi
    
    echo "$VM: Port=$PORT, IP=$IP"
done