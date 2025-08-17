# KB Setup Changes

## Summary
This update adapts the Knowledge Base deployment from a Docker-only workflow to an Ansible-based deployment targeting Debian VMs over SSH with public key authentication.

## Changes Made
- **Public Key Authentication**
  - Configured VMs to accept SSH connections using a dedicated private key (`~/.ssh/vbox-key`).
  - Updated `hosts.ini` to use `ansible_ssh_private_key_file` instead of password login.

- **File Transfer**
  - Added an Ansible `copy` task to upload the `knowledge-base/` directory (including `migrations/`) to the target VMs.

- **PostgreSQL Deployment**
  - Replaced `docker compose` with native PostgreSQL installation and service configuration on Debian.
  - Created PostgreSQL database (`knowledge_base`), user (`foo`), and password (`pass`) directly on the VM.

- **Migrations Execution**
  - Configured Ansible to run the database migrations using the `migrate` CLI tool after the DB becomes ready.

## Benefits
- No need to install or run Docker on the target VMs.
- Secure and automated deployment over SSH without manual password entry.
- Project files and migrations are deployed consistently to all target VMs.
- Ansible playbook can be rerun for idempotent updates.

## Next Steps
- Keep your SSH keys secure (`~/.ssh/vbox-key` private, `.pub` public).
- Place any future migrations inside the `knowledge-base/migrations/` folder before running `ansible-playbook`.
- To test connection to DB:
  ```bash
  psql -U foo -d knowledge_base -h 127.0.0.1