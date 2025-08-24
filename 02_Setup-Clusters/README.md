# Setup Clusters
Clusters are built from the virtual machines provisioned in Azure, and Kubernetes is deployed on top of them.

## Prerequisites
- SSH-Access to all your instances 
- Ansible: `brew install ansible` and check with `ansible --version`

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

## Deletion of clusters on the nodes

```Bash
# Delete previous Installations
sudo /usr/local/bin/k3s-agent-uninstall.sh #worker
sudo /usr/local/bin/k3s-uninstall.sh #master
```