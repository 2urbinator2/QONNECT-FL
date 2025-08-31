#!/bin/bash
# azure_vm_info.sh - Zeigt Public und Private IPs für Azure VMs

# Namen deiner VMs
VMS=(
    "cloud-energy-control"
    "cloud-energy-worker"
    "edge-energy-control"
    "edge-energy-worker"
    "fog-energy-control"
    "fog-energy-worker"
)

# Ressourcengruppe, in der deine VMs liegen
RESOURCE_GROUP="FelixSwarmchestrate"

echo "Azure VM Information (Public IP | Private IP)"
echo "---------------------------------------------"

for VM in "${VMS[@]}"; do
    # Private IP auslesen
    PRIVATE_IP=$(az vm list-ip-addresses \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM" \
        --query "[0].virtualMachine.network.privateIpAddresses[0]" \
        -o tsv 2>/dev/null)

    if [[ -z "$PRIVATE_IP" ]]; then
        PRIVATE_IP="nicht gefunden"
    fi

    # Public IP auslesen
    PUBLIC_IP=$(az vm list-ip-addresses \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM" \
        --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
        -o tsv 2>/dev/null)

    if [[ -z "$PUBLIC_IP" ]]; then
        PUBLIC_IP="nicht gefunden"
    fi

    echo "$VM: Public-IP=$PUBLIC_IP, Private-IP=$PRIVATE_IP"
done