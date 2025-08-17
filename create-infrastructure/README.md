# Create Cluster in Azure 

## Prerequisites
- Azure Account and Azure CLI
- Terraform

## Create Instances
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
