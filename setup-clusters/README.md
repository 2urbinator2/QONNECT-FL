# Setup Clusters
Clusters are built from the virtual machines provisioned in Azure, and Kubernetes is deployed on top of them.

## Prerequisites
- Ansible 

## Setup the clusters
1. Enter IP-Adresses in the inventory.yml
2. Run `ansible-playbook -i inventory.yml playbook.yml`

## Helpful Kubernetes Commands
