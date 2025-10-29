# Deploy Swarmchestrate in Azure

## Prerequisites
- helm (package manager for Kubernetes) on your host


## Installation
1. Clone: `git clone https://github.com/dos-group/QONNECT.git`
2. Prepare Clusters: `./boostrap all`
   - **Database:** You can access the database from every instance 
      1. Connect to a VM via SSH: `ssh -i ~/.ssh/az-key furban@172.206.193.15`
      2. Login:
            - DB-VM: `psql -U foo -d knowledge_base -h localhost` with `pass`
            - VM: `psql -h 10.0.1.4 -p 5432 -U foo -d knowledge_base`
      3. Use: `\x` to have a better overview and `\q` for logout
3. Deploy RLA (Cloud-Clusters)
      ```bash
      cd swarmchestrate-alternative/resource-lead-agent

      ____
      # Make the following changes under deploy/cm.yaml
      postgresdb:
         host: 10.0.1.10 # Use Privat IP of your DB-VM
      raft:
         id: 1 # Change ID on every cluster you deploy
         peers: # All Clusters you want to deploy RLA 
            - http://10.0.1.41:8080 # Use raft-lb external IP
      
      # Important comment out pvc.yaml in deploy/kustomization.yaml
      ____

      kubectl apply -k deploy
      ```
4. Deploy RA (Every cluster)
5. Remove the Repository: `sudo rm -r swarchestrate-alternative`
6. *Monitoring:* `./boostrap.sh monitoring`
      ```bash
      # Reach Prometheus of every cluster with Port-Forwarding 
      kubectl --context edge-energy -n monitoring port-forward svc/prometheus-server 9090:80

      # Reach Grafana of the Grafana cluster with Port Forwarding
      kubectl --context cloud-energy -n monitoring port-forward svc/grafana 9090:80 # User: admin, Password: Swarmchestrate

      ```


## Sources
[1] https://github.com/dos-group/swarmchestrate-alternative
[2] https://github.com/kubernetes-sigs/azurefile-csi-driver/tree/master/charts

## Problems
### Load Balancer
- *Problem:* Failed to allocate IP for "swarmchestrate/resource-lead-agent-lb": unknown pool "kind-cluster"
      ```bash 
      kubectl get svc -A -o yaml | grep -A5 "metallb.universe.tf/address-pool"
      # if: metallb.universe.tf/address-pool: kind-cluster

      kubectl patch svc resource-lead-agent-lb -n swarmchestrate \
      -p '{"metadata":{"annotations":{"metallb.universe.tf/address-pool":"resource-lead-agent-pool"}}}'
      ```

### PVC (File Share in Azure) 
- *Lösung:* Secret, PV and PVC are corrected 
    ```bash
    # Azure CSI Driver
    kubectl get pods -n kube-system | grep csi

    # Secret: Access key to the Storage Account
    kubectl get secret -n swarmchestrate

    # PV and PVC
    kubectl get pv
    kubectl get pvc -n swarmchestrate


    ```
### Image Resource Lead Agent
```bash
docker pull ghcr.io/mahmud2011/swarmchestrate/resource-lead-agent:0.1.0

docker tag ghcr.io/mahmud2011/swarmchestrate/resource-lead-agent:0.1.0 \
           ghcr.io/2urbinator2/resource-lead-agent:0.1.0-amd64

```