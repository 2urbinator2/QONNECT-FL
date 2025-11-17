# QONNECT in Azure with Runtime Optimisation


## Prerequisites
- Python3
- Terraform
- Kubernetes CLI
- Azure CLI
- Helm


## Deploy QONNECT
1. Create `venv` with requirements: `source scripts/create-venv.sh`  
2. Create infrastructure in Azure: `/01_Create-Infrastructure/README.md`



  !!!!!!Überarbeiten!!!!!!!!!
3. Setup the K3s and K8s clusters on the Azure VMs: `/02_Setup-Clusters/README.md`
4. Deploy QONNECT on the clusters: `/03_Deploy-QONNECT/README.md`



## Aktuell
```bash 
# cost 43, energy 44, performance 45, management vm
ssh -i ~/.ssh/az-key -L 6443:localhost:6443 furban@172.190.180.76 -fN  
ssh -i ~/.ssh/az-key -L 6444:localhost:6443 furban@172.171.229.149 -fN 
ssh -i ~/.ssh/az-key -L 6445:localhost:6443 furban@20.39.50.48 -fN
ssh -i ~/.ssh/az-key -L 5050:localhost:5050 furban@172.172.181.11 -fN
```

## Runtime Optimisation


