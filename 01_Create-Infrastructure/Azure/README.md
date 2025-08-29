# Create Cluster in Azure 

## Prerequisites
- Azure Account and Azure CLI
- Terraform





## Übersichtlcier
root.key → keep locally, secret, never share; used to sign client certificates
root.cer → upload to Azure VPN Gateway, public, can be shared
client.key → keep on client machine, secret, never share
client.cer → installed on client machine, signed by root, can be shared for authentication

```bash 
# Create certificates for authntifiction in VPN
./create-vpn-certificates.sh

# 2. Create ressources with terraform 
# 3. P2S-Konfiguration in Terraform 
```
Unbeachtet lassen:
- .ingore hinten an die file hängen

Verbinden









## Create Infrastructure
```bash
# Login 
az login

# Create Instances
terraform init
terraform plan
terraform apply

# Overview in Azure of the instances you have created
az resource list --resource-group FelixSwarmchestrate --output table

# Destroys all created resources
terraform destroy
# Hint: Check again all resources in the resource group

# Connect with the instances
ssh -i ~/.ssh/az-key furban@172.190.154.104

```

## Changes in the infrastructure
- Adding Instances:
  - just add a name for the instance in the variables.tf
