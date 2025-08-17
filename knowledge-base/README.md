# Knowledge Base Deployment (Debian VMs)

This setup deploys the Knowledge Base application and its PostgreSQL database on VirtualBox VMs using Ansible.

## Prerequisites

- A host machine with:
  - Ansible installed
  - SSH access to the VMs with public key authentication
- VMs with a user account (e.g., `vboxuser`) and sudo privileges
- SSH keypair generated on your host, e.g., `~/.ssh/vbox-key`

## Setup

1. **Update `hosts.ini`**
   - Set the correct IP address or hostname of the Debian VM where the database should be deployed.
2. **Apply Playbook**
    ```Bash
    cd knowledge-base
    ansible-playbook -i hosts.ini kb_setup.yml
    ```
