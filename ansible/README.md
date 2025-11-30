# Ansible deploy for Monitoring Stack

This Ansible playbook deploys the monitoring stack (core_agent, extended_agent, monitor_hub) to remote servers.

Files of interest:

- `inventory.ini` - example inventory with groups `monitoring` and `monitor_hub`.
- `playbook.yml` - main playbook; runs the `monitoring_stack` role on selected hosts.
- `roles/monitoring_stack/` - role that installs Docker/Python/Compose, creates the `monitoring` user, deploys the project, runs `docker compose up -d`, verifies containers, and adds an optional cron archive job.

Usage

1. Prepare inventory: edit `ansible/inventory.ini` and set `ansible_host` and `ansible_user` for your servers.

2. Edit variables if needed (either in the playbook vars or pass with `-e`):
   - `repo_url` (recommended): git URL of this project to clone on the remote host.
   - `project_dir`: default `/opt/monitoring-stack`.
   - Alternatively set `local_copy: true` and `local_src_path` to copy files from the control machine.

3. Run the playbook:

```powershell
# Run against inventory
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -u <ssh-user> --become
```

Examples

- Clone from Git (recommended):
```powershell
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -e "repo_url=https://github.com/your/repo.git" --become
```

- Copy from control node:
```powershell
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -e "local_copy=true local_src_path=/path/to/project" --become
```

Notes and caveats

- The role tries to install Docker using official distro repos and falls back to the Docker convenience script if necessary.
- The playbook installs `docker-compose` via `pip3` so `pip3` is required to be installed.
- This playbook is intended as a practical, extensible starting point. Review and harden (firewall, SELinux, non-root docker access) before using in production.
