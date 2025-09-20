#!/bin/bash
# vagrant_vm_info.sh - Zeigt Port und NAT-IP für mehrere Vagrant-VMs

VMS=(
    "Cloud-Energy-Control"
    "Cloud-Energy-Worker"
    "Edge-Energy-Control"
    "Edge-Energy-Worker"
)

echo "VM Information (Port | NAT-IP enp0s9 | Host-Only-IP enp0s10)"
echo "------------------------------------------------------------"

for VM in "${VMS[@]}"; do
    # Port aus ssh-config auslesen
    PORT=$(vagrant ssh-config "$VM" 2>/dev/null | awk '/Port/ {print $2}')
    
    # NAT-IP auslesen, fallback auf eth1 wenn enp0s9 fehlt
    NAT_IP=$(vagrant ssh "$VM" -c "ip -4 addr show dev enp0s9 2>/dev/null || ip -4 addr show dev eth1" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)

    if [[ -z "$NAT_IP" ]]; then
        NAT_IP="nicht gefunden"
    fi

    # Host-Only-IP auslesen (enp0s10)
    HOSTONLY_IP=$(vagrant ssh "$VM" -c "ip -4 addr show dev enp0s10 2>/dev/null" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)

    if [[ -z "$HOSTONLY_IP" ]]; then
        HOSTONLY_IP="nicht gefunden"
    fi
    
    echo "$VM: Port=$PORT, NAT-IP=$NAT_IP, Host-Only-IP=$HOSTONLY_IP"
done