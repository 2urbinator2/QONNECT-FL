
## Deploy QONNECT-FL

This guide outlines the three-step process for deploying the multi-cluster environment on Microsoft Azure.

## Prerequisites

Make sure you have the following tools and configurations ready before starting:
* **Terraform** (for infrastructure provisioning)
* **Kubernetes CLI (`kubectl`)** (for cluster management)
* **Azure CLI (`az`)** (for cloud provider access)
* **Helm** (for chart deployments)
* **Anaconda / Conda** (for environment management)
* **Azure Managed Identity** (for secure internal addressing)

## Step 1: Create Infrastructure in Azure

1. `cd 01_Create-Infrastructure`
2. Fill out: `terraform.tfvars`
3. (only the first time): `terraform init`
4. `terraform plan` and `terraform apply`
5. Fill out inventory: `../../inventory.yml`


## Step 2: Deploy Kubernetes & Set Up Cluster Management

1. `cd 02_Setup-Clusters`
2. Setup venv: `conda create -n qonnect python=3.10 -y` and `pip install -r ./requirements.txt`
3. Install Kubespray requirements: `ansible-playbook -i ../../inventory.yml ./install-infrastructure-deps.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"' --tags "all,spray,db"`
4. Clone Kubespray: `git clone https://github.com/kubernetes-sigs/kubespray.git` 
5. Fill out separate inventories.
6. `cd kubespray` and deploy (use separate terminals if needed): `ansible-playbook -i ../clusters/f-cost.ini cluster.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`
7. Setup cluster-management: `ansible-playbook -i ../../inventory.yml cluster-management.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`

## Step 3: Deploy QONNECT Components
Adapted from QONNECT[[1]](https://github.com/dos-group/QONNECT) and customized for Azure. (Note: Direct connection to clusters is not possible; access requires setting up an individual tunnel for each cluster.)

1. `cd 03_Deploy-QONNECT`

### Configure Knowledge_Base
1. Deploy `knowledge_base`: `./bootstrap.sh db`
2. Access KB in Browser: 
   1. `ssh -i ~/.ssh/az-key -L 5050:localhost:5050 xxx@xxx -fN`
   2. Connect via `ssh -i ~/.ssh/az-key xxx@xxx` and `source db-venv/bin/activate` and use `pgadmin4`
   3. `http://localhost:5050/`: **Email:** `foo@bar.com` and **Password:** `pass123456`

### Preparation Steps
1. `./bootstrap.sh all`
2. Create a **managed identity** and fill out `azure.json`
3. `./bootstrap.sh si`
4. `./bootstrap.sh sd`
   * Note: Discs have to be allocated in Azure first.

### Deploy Orchestrator Components 
1. Deploy RLA: `kubectl apply -k deploy-RLA --context=cloud`
   1. Adapt `DB` Connection
   2. Adaptations in `cm`
      1. For the peers: External IP of the LB in `Swarmchestrate` and change `ID`
      2. Change `volumeHandle`in `pv`
2. Deploy RA: `kubectl apply -k deploy-RA --context=edge-energy`
   1.  Chose `app.type`: cloud, fog, edge
   2.  Enter `external-IP` of `ingress-nginx-controller-internal` in `host`