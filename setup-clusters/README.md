# Setup Clusters
Clusters are built from the virtual machines provisioned in Azure, and Kubernetes is deployed on top of them.

## Prerequisites
- Ansible 
- (only for centralized cluster Management): Kubectl CLI

## Hints
Currently on every cluster k3s is running regardless if it is a cloud, edge or fog cluster

## Setup the clusters
1. Enter IP-Adresses in the inventory.yml:
   - `cloud-energy-master ansible_host=xxx private_ip=xxx`
   - this host name has to follow this semantic
2. Run `ansible-playbook -i inventory.yml playbook.yml`
3. (optional) Setting up centralized Kubernetes Cluster Management (see below)
   - Note: It has to be deletetd 

## Helpful Commands whether the clusters are running
```bash
# Connect with the instances
ssh -i ~/.ssh/az-key furban@172.190.154.104

# Checks the k3s status: Should be active
sudo systemctl status k3s

# Shows all nodes within the cluster
sudo k3s kubectl get nodes -o wide
```

## Centralized Kubernetes Cluster Management
```bash 
# Create centralized cluster management
# 1. Create and delete directory for the kube files
mkdir -p ~/.kube/k3s-clusters

# 2. Copy config files
ssh -i ~/.ssh/az-key furban@172.174.19.157 "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/k3s-clusters/cloud-energy.yaml
ssh -i ~/.ssh/az-key furban@20.169.174.49 "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/k3s-clusters/fog-energy.yaml
ls -l ~/.kube/k3s-clusters/

# 3. Change IP in Server into public IP of the server
nano ~/.kube/k3s-clusters/fog-energy.yaml
# Change every deafult value into the cluster name 

# 4. Merge Cluster Files
export KUBECONFIG=~/.kube/k3s-clusters/cloud-energy.yaml:~/.kube/k3s-clusters/fog-energy.yaml
kubectl config view --merge --flatten > ~/.kube/config

# Delete everything
rm -rf ~/.kube/k3s-clusters/
unset KUBECONFIG

# Helpful Commands
# Shows all clusters
kubectl config get-contexts

# Shows current cluster
kubectl config current-context

# Changes cluster
kubectl config use-context <cluster-name>
```