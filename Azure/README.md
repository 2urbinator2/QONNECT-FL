# Create Cluster in Azure 

## Prerequisites
- Azure Account and Azure CLI
- Terraform

## Create Infrastructure
```bash
# Create Infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# Create virtual environment and install requirements 
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Get basic data for inventory file
cd ..
./data-vms.sh

# Install k3s on all non cloud nodes
ansible-playbook -i inventory.yml playbooks/k3s-setup.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'


```