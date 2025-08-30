# Central Cluster Management
After the infrastructure has been provisioned and Kubernetes is running on the clusters, this step sets up the central cluster management from the host.

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
6. (Only for VBox) Open the file `nano ~/.kube/vbox-cluster/fog-energy.yaml` and change the localhost `server: https://127.0.0.1:6443`to the en0s9 from the master VM
7. (only for Azure) Port Forwarding: `ssh -i ~/.ssh/az-key -L 6443:localhost:6443 furban@172.190.222.149`
8. Manuel Testing (optinal): `kubectl --kubeconfig ~/.kube/vbox-cluster/fog-energy.yaml get nodes`
9. Rename the clusters: `kubectl --kubeconfig ~/.kube/vbox-cluster/fog-energy.yaml config rename-context default fog-energy `
10. Merge the config files into one to have a centralised cluster Mangement: `KUBECONFIG=~/.kube/vbox-cluster/cloud-energy.yaml:~/.kube/vbox-cluster/fog-energy.yaml kubectl config view --flatten > ~/.kube/config`

11. **Virtual Private Network (VPN):** Another but expensive solution


