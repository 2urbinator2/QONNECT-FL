# QONNECT in Azure with Runtime Optimisation


## Deploy QONNECT
1. Connect with Azure via CLI 
2. Create `venv` with requirements: `source scripts/create-venv.sh`  
3. Create infrastructure in Azure  
   1. `cd 01_Create-Infrastructure-Azure` 
   2. Fill out: `terraform.tfvars`
   3. (only first time):`terraform init`
   4. `terraform plan` and `terraform apply`
   5. `cd ..`
4. Create clusters by deploying K8S and K3S (!!!!!! Überarbeiten!!!!!!!)
  - hier müssen direkt die inventory files vorbereitet werden


## Runtime Optimisation


