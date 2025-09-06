# Generelle Readme

## Smaller Things
### Tastenbefehle 
- mehrere Zeilen kommentieren: cmd + k + c, cmd + k + u


### Virtual Environment Python
- auf dem Mac ist 2x mal Python installiert 
  - Mac /opt/homebrew/bin/python3
  - Vev: /Users/urbani/Nextcloud2/Masterarbeit/master-thesis/02_Knowledge-Base/02_Anwendungsbereitstellung/App-Deployment-Testing/venv/bin/python3
  - 
```bash
# Erstellt venv auf dem aktuellem system python
python3 -m venv venv

# Erstellt die venv sicher auf dem brew python (besser)
/opt/homebrew/bin/python3 -m venv venv

# Pakete abfragen
ansible --version

# (De-)Aktivieren
source venv/bin/activate
deactivate

#Löschen
rm -rf venv

# Installation der requirements.txt
pip install -r requirements.txt
```
### SSH
```bash 
ls ~/.ssh
ssh -i ~/.ssh/az-key furban@172.190.154.104


```

### Ping
```bash
# VirtualBox
ping -c 4 -I enp0s10  192.168.56.38

ping 10.0.1.7
```

## Virtualbox

**Problem manuelles Erstellen der Instanzen:**  
- Eine Erstellung von Instanzne mittels BashScript oder über die Gui ist sehr aufwendig
  - Eine Erleichterung liefert das Klonen von Instanzen
  - *Sudo-Rechte:* Sudo-Rechte müssen manuell auf den Instanzen vergeben werden, um beispielsweise Updates ausführen zu können
  - *SSH-Zugriff.*
    - es muss ein SSH key für den Zugriff auf die Instanzen erstellt werden 
    - key muss jedes mal manuel mit eingegeben werden
- Lösung: Verwendung von *Vagrant*

### Vagrant
- Vagrant ähnlich zu terraform für VirtualBox
  - Einfaches, schnelles Erstellen und Löschen von Instanzen
- Anstatt die ISO manuel downloaden zu müssen werden hier vorgefertigte Boxen verwendet
- 4 Befehle:
  - `Vagrant init` erstellt die Vagrant file, in der die Infrastruktur definiert
  - `Vagrant up` erstellt die Resourcen gemäß der Vagrantfile, `Vagrant halt` hält die VMs an und `Vagrant destroy` zerstört alles

**Erklärung Vagrant File:**
- Verwendete Box wird angegeben: Ubuntu
- Nat-Netzwerk
  - Prüfen, ob Nat Netzwerk bereits vorhanden ist 
  - falls nicht wird eins erstellt mit *DHCP* 
- VM-Namen: Namen, sowie Paramter werden angegeben
- Instanzen werden erstellt:
  - Auf adapter 3 wird noch ein Host-Only Netzwerk gelegt
  - Instanzen werden an das Natnetzwerk gehängt
- Provision:
  - installiert dhcp client auf den Instazen und ordnet diesen IPs zu für Nat-Netzwerk

***Hilfreiche Commands***
```bash
# Prüfen der IP für das NAT-Netzwerk 
ip -4 addr show dev enp0s9 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
```

## Azure
```bash 
# Login 
az login

# Overview in Azure of the instances you have created
az resource list --resource-group FelixSwarmchestrate --output table

```

## IaC
### Terraform
```bash
# Create Instances
terraform init
terraform plan
terraform apply

# Destroys all created resources
terraform destroy
```

### Ansible
```bash 
ansible-playbook -i inventory.yml playbook.yml
ansible-playbook -i inventory.yml playbook.yml --ssh-common-args="-o IdentitiesOnly=yes -o StrictHostKeyChecking=no"
```

### Terraform 

## Kubernetes
**K3s Deployment**
```Bash
# Check if it`s working
sudo systemctl status k3s # Master
sudo systemctl status k3s-agent # Worker
sudo k3s kubectl get nodes -o wide # Both

# Delete previous Installations
sudo /usr/local/bin/k3s-agent-uninstall.sh #worker
sudo /usr/local/bin/k3s-uninstall.sh #master
```
**K5s Deployment**
`sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes`


### Kubernetes CLI
```bash
# Installation
brew install kubectl
mkdir -p ~/.kube
kubectl version --client

# Removal
brew uninstall kubectl
rm -rf ~/.kube

ls ~/.kube/
rm -rf ~/.kube/vbox-cluster

# Switch clusters 

```  

### Helpful Kubernetes Commands
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

### Azure Kubernetes Service (AKS)
Managed Kubernetes, der das Erstellen, Skalieren und Verwalten von Container Anwendungen vereinfacht