# Setup Clusters
Clusters are built from the virtual machines provisioned in Azure, and Kubernetes is deployed on top of them.

## Prerequisites
- Ansible 

## Hints
Currently on every cluster k3s is running regardless if it is a cloud, edge or fog cluster

## Setup the clusters
1. Enter IP-Adresses in the inventory.yml:
   - `cloud-energy-master ansible_host=xxx private_ip=xxx`
   - this host name has to follow this semantic
2. Run `ansible-playbook -i inventory.yml playbook.yml`

## Helpful Commands whether the clusters are running

```bash
# Checks the k3s status: Should be active
sudo systemctl status k3s

# Shows all nodes within the cluster
sudo k3s kubectl get nodes -o wide
```