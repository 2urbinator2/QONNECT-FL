# Central Cluster Management
After the infrastructure has been provisioned and Kubernetes is running on the clusters, this step sets up the central cluster management from the host.

## Install Kubectl CLI with brew (Mac OS)
1. Uninstallation to have a fresh start 
    ```bash
    ls ~/.kube # Check whether folder exists 
    rm -rf ~/.kube
    brew uninstall kubectl
    ```
2. Installation
    ```bash
    brew install kubectl
    mkdir -p ~/.kube # Folder for all config files
    kubectl version --client
    ```

## Steps for VirtualBox
1. Create a folder for all VBox clusters: `mkdir -p ~/.kube/vbox-cluster`
2. Check whether *kubeconfig* files are on the *master nodes*: Connect with`ssh -i ~/.ssh/vbox-key furban@192.168.56.5` and check `ls /etc/rancher/k3s` for *k3s.yaml*
3. You have to make API-server available for your host (be carefully with the identations):
    ```bash
    sudo nano /etc/rancher/k3s/config.yaml

    # Put the Folloging in the file with the enp0s9 
    advertise-address: "192.168.56.101"
    tls-san:
    - "192.168.56.101"
    ```
4. Restart K3s: `sudo systemctl restart k3s`
5. Copy cluster config file to your local Kubernetes CLI (Change Name): `ssh -i ~/.ssh/vbox-key furban@192.168.56.5 "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/vbox-cluster/fog-energy.yaml`
6. Open the file `nano ~/.kube/vbox-cluster/fog-energy.yaml` and change the localhost `server: https://127.0.0.1:6443`to the en0s9 from the master VM
7. Manuel Testing (optinal): `kubectl --kubeconfig ~/.kube/vbox-cluster/fog-energy.yaml get nodes`
8. Rename the clusters: `kubectl --kubeconfig ~/.kube/vbox-cluster/fog-energy.yaml config rename-context default fog-energy `
9.  Merge the config files into one to have a centralised cluster Mangement: `KUBECONFIG=~/.kube/vbox-cluster/cloud-energy.yaml:~/.kube/vbox-cluster/fog-energy.yaml kubectl config view --flatten > ~/.kube/config`

## Steps for Azure

## Helpful Kubernetes Commands
```bash 
# Cluster Commands
kubectl config get-contexts # Shows all clusters
kubectl config current-context # Shows current cluster
kubectl config use-context name # Changes current cluster

# Request commands in a cluster
kubectl get all
kubectl get po
kubectl get ns
kubectl get svc
kubectl get no
kubectl get deploy

```