# Create and Setup Cluster 

## Prerequisites
- **All** 
  - Python
  - Kubernetes CLI
- ***VirtualBox***
  - VirtualBox
  - Vagrant
- ***Azure***
  - Azure Account and Azure CLI
  - SSH-Key
  - Terraform

## Resource creation and setup
### 1. Create Virtual Environment 
```bash
/opt/homebrew/bin/python3 -m venv venv

source venv/bin/activate
pip3 install -r requirements.txt
```

### 2. Create Infrastructure
- ***VirtualBox:*** `vagrant up`
- ***Azure:***
  ```bash
  cd terraform
  terraform init
  terraform plan
  terraform apply
  cd ..
  ```

### 3. (optional) Get information for the inventory files
- ***VirtualBox:*** `./resource-data/vb-data-vms.sh`
- ***Azure:*** `./resource-data/az-data-vms.sh`

### 4. Setup inventory
- ***VirtualBox:*** K3s on all nodes
    ```bash
    # Fill out inventory/vb-k3s-inventory.yml with only your edge and fog nodes and apply
    ansible-playbook -i inventory/vb-k3s-inventory.yml playbooks/vb-k3s-setup.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'
    ```

- ***Azure:***
  - *K3s* on non-cloud nodes:
    ```bash
    # Fill out az-k3s-inventory.yml with only your edge and fog nodes and apply
    ansible-playbook -i inventory/az-k3s-inventory.yml playbooks/az-k3s-setup.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'
    ```
  - *K8s* on cloud nodes: Currently you have to do it for Cloud (f.i. you have to cloud clusters you have to di this step two times)
    ```bash
    # Clone the repository
    git clone https://github.com/kubernetes-sigs/kubespray.git
    cd kubespray

    # Fill out inventory in kubespray/inventory/mycluster
    cp -r inventory/sample inventory/mycluster

    # Change the following
    cloud-energy-control ansible_host=172.174.34.108  ip=10.0.1.4 
    
    # Add the following 
    [all:vars]
    ansible_user=furban
    ansible_ssh_private_key_file=~/.ssh/az-key
    ansible_become=true
    ansible_become_method=sudo
    
    # Execute
    ansible-playbook -i  inventory/mycluster/inventory.ini  cluster.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'

    # Remove the repository
    cd ..
    sudo rm -r kubespray
    ```

### 5. Setup Central Cluster Management
- ***VirtualBox:*** `ansible-playbook -i inventory/vb-k3s-inventory.yml playbooks/vb-cluster-management.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`
- ***Azure:***`ansible-playbook -i inventory/az-k3s-inventory.yml playbooks/az-cluster-management.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`
  - Create tunnel to every cluster: `ssh -i ~/.ssh/az-key -L 6443:localhost:6443 user@cluster1 -fN` 
  - See SSH-Connections with: `lsof -iTCP -sTCP:LISTEN | grep ssh`
  - Delete tunnel with: `kill 12345`
  - Aktuell: 
    ```bash
    ssh -i ~/.ssh/az-key -L 6443:localhost:6443 furban@20.39.41.4 -fN
    ssh -i ~/.ssh/az-key -L 6445:localhost:6443 furban@20.39.50.134 -fN
    ssh -i ~/.ssh/az-key -L 6444:localhost:6443 furban@172.171.216.162 -fN
    ```





