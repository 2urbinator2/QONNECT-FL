# Setup Cluster 


## Resource creation and setup
0. Install dependencies on all clusters:
1. Install K8s on Cloud Clusters:
2. Install K3s on Edge and Fog Clusters: 
3. Port Forwarding to access the clusters in the Kubernetes CLI:
    ```bash
    ssh -i ~/.ssh/az-key -L 6443:localhost:6443 furban@172.171.229.149 -fN  
    ssh -i ~/.ssh/az-key -L 6444:localhost:6443 furban@52.226.125.34 -fN 
    ```

   





4. Deploy K3s and K8s clusters on the infrastructure
    - ***K3S (Edge and Fog):*** Fillout `az-k3s-inventory.yml` (cloud nodes as well) and deploy with `ansible-playbook -i inventory.yml playbooks/k3s-setup.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`
    - ***K8S (Cloud):*** Using Kubespray (You have to do it manually for every cluster)
      ```bash
      git clone https://github.com/kubernetes-sigs/kubespray.git
      cd kubespray

      # Fill out inventory in kubespray/inventory/mycluster
      cp -r inventory/sample inventory/mycluster

      # Make the Following Changes
      cloud-energy-control ansible_host=172.174.34.108  ip=10.0.1.4 
      
      # Add the following 
      [all:vars]
      ansible_user=furban
      ansible_ssh_private_key_file=~/.ssh/az-key
      ansible_become=true
      ansible_become_method=sudo
      
      # Execution and Removal
      ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'
      cd ..
      sudo rm -r kubespray
      ```

5. Cluster Management with Kubernetes CLI: `ansible-playbook -i inventory.yml playbooks/cluster-management.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`
    ```bash
      # Create tunnel to every cluster to see all clusters in Kubernetes CLI: 
      ssh -i ~/.ssh/az-key -L 6443:localhost:6443 furban@20.121.187.237 -fN # Cost 
      ssh -i ~/.ssh/az-key -L 6444:localhost:6443 furban@52.190.8.131 -fN # Energy
      ssh -i ~/.ssh/az-key -L 6445:localhost:6443 furban@52.234.224.42 -fN # Performance
     
      # See all Connections
      lsof -iTCP -sTCP:LISTEN | grep ssh
      ps aux | grep '[s]sh'

      # Delete tunnel
      kill 12345
      
      # Shows Files in the Kube Folde 
      ls ~/.kube

      # Removes Files 
      rm -r ~/.kube/cache
      rm -r ~/.kube/config
      rm -r ~/.kube/az-cluster

      # Set at the beginning 
      kubectl config use-context cloud-energy
    ```



## Cluster information
- DB: 4GB
- Energy
  - Cloud: 8GB
  - Edge: 4GB
  - Fog
- Performance: 
  - Cloud: 4 GB
  - Edge
  - Fog
- Cost
  - Cloud 4 GB
  - Edge
  - Fog

```bash

az vm list-sizes --location eastus --query "[?starts_with(name, 'Standard_B')]" --output table

# Infomation about the architecture
https://azure.microsoft.com/de-de/pricing/details/virtual-machines/linux/#bs-series

```