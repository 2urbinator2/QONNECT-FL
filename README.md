# Setup Swarmchestrate on Azure

1. Follow README.md in create-vms to create VMs for the clusters in Azure
2. Follow Readme.md in setup-clusters 
   1. to setup the clusters




central cluster Mangement

1. Kubeconfig von den K3s-odes exportieren
kubeconfig file in jedem Master node unter: `/etc/rancher/k3s/k3s.yaml`

2. API-Server von außen errreichbar machen
netstat -an | grep 6443 --> zeigt alle verbindungen zum Port 6443 auf der Instanz

6443 ist der k3s API Server 


auf master Instanzen:
ls /etc/rancher/k3s --> nur gucken, ob das verezihnis exiistiert 
sudo nano /etc/rancher/k3s/config.yaml folgendes rein mit der IP des clusters
```bash
advertise-address: "192.168.56.101"
tls-san:
  - "192.168.56.101"
```
sudo systemctl restart k3s -> Instnaz neustarten



1. Kzbeconfig auf den Host Kopieren

2. Merhere Kontexte verwalten



Zum löschen in dem Directory:
rm ~/.kube/k3s-clusters/cluster1.yaml

Aufrufen