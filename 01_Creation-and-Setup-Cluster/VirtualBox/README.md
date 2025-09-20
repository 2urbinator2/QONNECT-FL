# Cluster Creation and Setup in VirtualBox

## Prerequisites
- Python
- Kubernetes CLI
- VirtualBox
- Vagrant

## Resource creation and setup
1. Create Virtual Environment 
    ```bash
    /opt/homebrew/bin/python3 -m venv venv

    source venv/bin/activate
    pip3 install -r requirements.txt
    ```

2. Create VMs in VirtualBox and get properties of the instances
   1. `vagrant up`
   2. `./vb-data-vms.sh`

3. Deploy K3s on every node
   1. Fill out `inventory.yml`
   2. Deploy with `ansible-playbook -i vb-k3s-inventory.yml playbooks/vb-k3s-setup.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`

4. Setup central cluster management with Kubernetes CLI: `ansible-playbook -i vb-k3s-inventory.yml playbooks/vb-cluster-management.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`