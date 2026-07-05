# Quick Start Guide

## Installation

```bash
# Install Ansible
pip install ansible>=2.10

# Clone this project
cd projects/2026-07-05_ansible-webserver-deploy

# Verify Ansible is working
ansible --version
```

## Configuration

### 1. Prepare SSH Access
```bash
# Generate SSH keys if needed
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Add servers to known_hosts
ssh-keyscan -H 192.168.1.100 >> ~/.ssh/known_hosts
ssh-keyscan -H 192.168.1.50 >> ~/.ssh/known_hosts
```

### 2. Update Inventory
Edit `inventory.yml` with your actual server IPs:
```yaml
webservers:
  hosts:
    web1:
      ansible_host: YOUR_WEB_SERVER_IP
```

### 3. Verify Connectivity
```bash
# Test connection to all hosts
ansible all -i inventory.yml -m ping

# Gather system facts
ansible all -i inventory.yml -m setup -a "filter=ansible_os_family"
```

## Deployment

### Full Stack Deployment
```bash
# Syntax check
ansible-playbook playbooks/site.yml --syntax-check

# Dry-run (no changes)
ansible-playbook playbooks/site.yml --check

# Deploy everything
ansible-playbook playbooks/site.yml -v
```

### Selective Deployment
```bash
# Deploy only webservers
ansible-playbook playbooks/webservers.yml

# Deploy only database
ansible-playbook playbooks/database.yml

# Deploy only monitoring
ansible-playbook playbooks/monitoring.yml
```

### Deploy Specific Roles
```bash
# Deploy only webserver role with tag
ansible-playbook playbooks/site.yml --tags "webserver"

# Skip service restart
ansible-playbook playbooks/site.yml --skip-tags "service-start"
```

## Verification

### Check Service Status
```bash
# SSH to server and check services
ssh ubuntu@192.168.1.100
systemctl status nginx
systemctl status php8.2-fpm

# PostgreSQL
ssh ubuntu@192.168.1.50
sudo -u postgres psql -c "\list"

# Node Exporter
curl http://192.168.1.100:9100/metrics | head -20
```

### Run Validation Playbook
```bash
ansible-playbook tests/test-connection.yml -v
```

## Common Commands

```bash
# List all hosts
ansible all -i inventory.yml --list-hosts

# Run ad-hoc commands
ansible webservers -i inventory.yml -m shell -a "systemctl status nginx"

# Check specific variable
ansible webservers -i inventory.yml -m debug -a "var=nginx_port"

# Gather facts only
ansible all -i inventory.yml -m setup > facts.json

# Verbose output (add more v's for debug)
ansible-playbook playbooks/site.yml -vvv

# Limit to specific host
ansible-playbook playbooks/site.yml -l web1

# Become root
ansible-playbook playbooks/site.yml --become
```

## Troubleshooting

### SSH Connection Issues
```bash
# Test SSH directly
ssh -v ubuntu@192.168.1.100

# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 700 ~/.ssh
```

### Ansible Issues
```bash
# Check inventory syntax
ansible-inventory -i inventory.yml --graph

# Debug playbook execution
ansible-playbook playbooks/site.yml -vvvv --step

# Check facts on specific host
ansible web1 -m setup -a "filter=ansible_default_ipv4"
```

### Service Issues
```bash
# Manually restart service
ansible webservers -m systemd -a "name=nginx state=restarted"

# Check logs
ansible webservers -m shell -a "journalctl -u nginx -n 50"
```

## Next Steps

1. **Customize variables** - Edit `group_vars/*.yml` for your environment
2. **Add templates** - Create custom configs in `roles/*/templates/`
3. **Extend roles** - Add more tasks for your specific needs
4. **Setup Vault** - Secure sensitive data with `ansible-vault`
5. **Create inventory groups** - Add more groups for different environments

## Resources

- Ansible Docs: https://docs.ansible.com/
- Ansible Galaxy: https://galaxy.ansible.com/
- Best Practices: https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
