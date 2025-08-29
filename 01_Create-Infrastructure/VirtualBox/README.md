# Virtual Box 




## Prerequisites
- Python
- Vagrant

## Create Infrastructure
```bash
# Create virtual environment and install requirements 
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Create resources with vagrant
vagrant up 

# Fill out port and private_ip inventory yml, you can use the following comand to receive the information
./data-vms.sh

# Deploy K3s on the instances 
ansible-playbook -i inventory.yml playbooks/k3s-setup.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'




```

## Further settings
```bash
ansible --version
deactivate
rm -rf venv
```

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

















