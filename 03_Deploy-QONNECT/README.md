# Deploy Qonnect in Azure


## How to deploy Qonnect?

### 1. Deploy Database and Prepare the Clusters
1. Deploy the `knowladge_base` db `central-management-vm`: `./setup-qonnect db`
2. Prepare the clusters: `./setup-qonnect all`

### 2. Deploy RLAs on K8s Cloud Clusters
1. Fill out: `azurestorageaccountkey:` in `deploy-RLA/secret.yaml.example`
   - Find out key: `az storage account keys list --account-name myclusterfiles --resource-group my-rg --query "[0].value" -o tsv`
2. Fill out (narrow down individually the area): `addresses:` (3 are enough) in `config/metallb.yaml`
   1. Deploy Metal-lb on the cluster: `./setup-qonnect mlb`
3. Make the following changes in `deploy-RLA/cm.yaml`:
   1. Use `Privat IP` of the `central-management-vm`in `postgresdb:` for `host:`
   2. Use unique `id:` and enter all `EXTERNAL-LP` of every LoadBalancer from `swarmchestrate` in `peers`
4. Deploy RLA: `kubectl apply -k deploy-RLA`

### 3. Deploy RAs on every Cluster
1. Make the following changes:
   1. Chose depending on your cluster `app.type`: cloud, fog, edge
   2. Enter `EXTERNAL-LP` of the LoadBalancer from `ingress-nginx` of cloud-cluster
2. Deploy RA: `kubectl apply -k deploy-RA`


## How to setup Monitoring and Chaos Testing
1. `./observe-and-chaos.sh prometheus`
1. Setup Chaos-Testing: `./observe-and-chaos.sh chaos-mesh`

## Comments 
### Knowledge-base
1. Connect via ssh to `central-management-vm`
2. `source db-venv/bin/activate` and use `pgadmin4`
   1. (only first time:) Enter **Email:** `foo@bar.com` and **Password:** `pass123456`
3. Open a new terminal and start port forwarding with a tunnel: `ssh -i <ssh-key> -L 5050:localhost:5050 <admin_username>@<pIP central-management-vm>  -fN`
4. `http://localhost:5050/` and login with data from `2.1.`
5. Add database:
   1. **Server Name:** `QONNECT`
   2. **Host:** `localhost`
   3. **Port:** `5432`
   4. **Database:** `knowledge_base`
   5. **Username:** `foo`
   6. **Password:** `pass`

### PVC in RLA
In Azure, PVCs cannot request storage space as easily as in Docker. Instead of each PVC making an individual claim, all of them are now placed in a single Azure File Share and configured as follows:
1. In `01_Create-Infrastructure` a 10 GB File-Share in Azure is created
2. With the help of `setup-driver` in `setup-qonnect.sh` a azure csi driver to the file share is deployed in `kube-system` on the cloud clusters
3. A Secret with the key to the file share is deployed in swarmchestrate namespace
4. A PV which points on the File Share is created 
5. A PVC in `swarmchestrate`namespace is created which points on the PV

## Sources
[1] https://github.com/dos-group/swarmchestrate-alternative
[2] https://github.com/kubernetes-sigs/azurefile-csi-driver/tree/master/charts