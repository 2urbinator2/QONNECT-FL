# Setup Clusters
Clusters are built from the virtual machines provisioned in Azure, and Kubernetes is deployed on top of them.

## Prerequisites
- SSH-Access to all your instances 
- Ansible 
- (only for centralized cluster Management): Kubectl CLI

## Setup the clusters
1. Fill out the `inventory.yml`
   -   *For VBox:* 
       - Change the hostname (Hostname != VM-Name): `sudo hostnamectl set-hostname control`
       - To get enp0s8 use `ip -4 addr show dev enp0s8 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'` and enp0s8 use `ip -4 addr show dev enp0s9 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'`
2. Run `ansible-playbook -i inventory.yml playbook.yml` 
3. (Optional) Check on your VMs
   ```bash
   sudo systemctl status k3s # Master
   sudo systemctl status k3s-agent # Worker
   sudo k3s kubectl get nodes -o wide # Both
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

# (4) Testen: Dauerhafter Merge
KUBECONFIG=~/.kube/k3s-clusters/cloud-energy.yaml:~/.kube/k3s-clusters/fog-energy.yaml \
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

# VPN
- Zertifikate
  - Root-Zertifikat
  - Client Zertifikat


## Helpful commands in case of problems with the k3s-setup

```Bash
# Network/Connectivity
curl -k https://192.168.56.6:6443
nc -vz 192.168.56.6  6443

# Token/Node Authentification
sudo cat /var/lib/rancher/k3s/server/node-token # Master 
ssh -i ~/.ssh/key-inst furban@192.168.56.6 "sudo cat /var/lib/rancher/k3s/server/node-token" # Worker

# Delete previous Installations
sudo /usr/local/bin/k3s-agent-uninstall.sh #worker
sudo /usr/local/bin/k3s-uninstall.sh #master
```