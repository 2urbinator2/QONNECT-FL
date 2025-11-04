# Deploy Qonnect in Azure



## How to?
1. Deploy the `knowladge_base` db `central-management-vm`: `./boostrap db`



## Knowledge-base db
The `knowladge_base` database is located on the `central-management-vm`:
- you can check on `central-management-vm` whether db is running: `sudo systemctl status postgresql`
- you can access and leave the database on `central-management-vm` with: `psql -U foo -d knowledge_base -h localhost`and `\q`

Due to `pgAdmin` it is also possible to access the db in the browser of your host
1. Connect to `central-management-vm` via SSH
2. Activate `source db-venv/bin/activate` and start pgAdmin with `pgadmin4`
   - **Email:** `foo@bar.com`
   - **Password:** `pass123456`
3. Start tunnel: `ssh -i <ssh-key> -L 5050:localhost:5050 <admin_username>@<pIP central-management-vm>  -fN`
   1. Reach the DB in your browser: `http://localhost:5050/`
















## Prerequisites
- helm (package manager for Kubernetes) on your host


## Installation
1. Clone: `git clone https://github.com/dos-group/QONNECT.git`
2. Prepare Clusters: `./boostrap all`
   



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