# Virtual Box 




## Prerequisites
- Python
- Vagrant
- Kubernetes CLI

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

#
ansible-playbook -i inventory.yml playbooks/cluster-management.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'

```




    












