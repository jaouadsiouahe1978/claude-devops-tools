# Ansible Server Hardening & Configuration Management

## Description

Automate server hardening, package management, and security configuration across multiple Linux servers using Ansible. This project demonstrates core Ansible concepts including roles, handlers, templates, and inventory management for production-grade infrastructure automation.

## Objectives

- Learn Ansible playbook structure and best practices
- Implement multi-server configuration management with roles
- Apply security hardening techniques (SSH, firewall, users)
- Use handlers for idempotent configuration changes
- Manage inventory and group variables effectively
- Deploy templated configuration files

## Technologies Used

- **Ansible**: Infrastructure automation framework
- **Linux**: Ubuntu/CentOS servers (local VMs or Docker containers)
- **SSH**: Remote command execution
- **Jinja2 Templates**: Dynamic configuration generation

## Prerequisites

```bash
# Install Ansible
pip install ansible

# Verify installation
ansible --version

# For local testing with Docker (optional)
docker run -d --name server1 -d ubuntu:22.04 sleep infinity
docker run -d --name server2 -d ubuntu:22.04 sleep infinity
```

## Project Structure

```
.
├── inventory/
│   ├── hosts                 # Static inventory file
│   └── aws_ec2.yml          # Dynamic inventory example
├── group_vars/
│   ├── all.yml              # Variables for all hosts
│   ├── webservers.yml       # Variables for webservers group
│   └── databases.yml        # Variables for databases group
├── host_vars/
│   └── server1.yml          # Host-specific variables
├── roles/
│   ├── common/              # Common setup role
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/
│   │   └── files/
│   ├── security/            # Security hardening role
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/sshd_config.j2
│   │   └── files/
│   ├── webserver/           # Nginx setup role
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/nginx.conf.j2
│   │   └── files/
│   └── monitoring/          # Node exporter setup
│       ├── tasks/main.yml
│       └── handlers/main.yml
├── site.yml                 # Main playbook
├── webservers.yml           # Webserver-specific playbook
├── test-playbook.yml        # Testing playbook
└── ansible.cfg              # Ansible configuration
```

## Realization Steps

### 1. Install Ansible
```bash
pip install ansible
```

### 2. Prepare Inventory
- Define hosts in `inventory/hosts` with groups (webservers, databases)
- Use host variables and group variables for customization

### 3. Create Roles
- **common**: System updates, users, sudo, basic packages
- **security**: SSH hardening, firewall rules, fail2ban
- **webserver**: Nginx installation and configuration
- **monitoring**: Prometheus node exporter setup

### 4. Run Playbooks
```bash
# Run all roles on all hosts
ansible-playbook site.yml -i inventory/hosts

# Run only on webservers
ansible-playbook webservers.yml -i inventory/hosts

# Run with verbose output
ansible-playbook site.yml -i inventory/hosts -v

# Dry-run to check changes
ansible-playbook site.yml -i inventory/hosts --check
```

### 5. Test and Verify
```bash
# Test connectivity
ansible -i inventory/hosts all -m ping

# Get facts from hosts
ansible -i inventory/hosts all -m setup | less

# Ad-hoc commands
ansible -i inventory/hosts webservers -m command -a "uptime"
```

## What You'll Learn

✓ **Ansible Architecture**: Control node, managed nodes, inventory, modules  
✓ **Playbooks & Tasks**: Declarative infrastructure code  
✓ **Roles**: Organized, reusable automation components  
✓ **Handlers**: Triggering services restarts efficiently  
✓ **Jinja2 Templates**: Dynamic configuration generation  
✓ **Variables & Facts**: Host-specific and group-based data  
✓ **Idempotency**: Safe to run playbooks multiple times  
✓ **Security Best Practices**: SSH hardening, firewall, user management  

## Testing Locally

### Option 1: Docker Containers
```bash
# Start 2 Ubuntu containers
docker run -d --name server1 -it ubuntu:22.04 sleep infinity
docker run -d --name server2 -it ubuntu:22.04 sleep infinity

# Install SSH server
docker exec server1 apt-get update && apt-get install -y openssh-server sudo
docker exec server2 apt-get update && apt-get install -y openssh-server sudo

# Get container IPs
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server1
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server2

# Update inventory with container IPs
# Run playbook
ansible-playbook site.yml -i inventory/hosts -k
```

### Option 2: Vagrant VMs
```bash
vagrant up
ansible-playbook site.yml -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
```

## Common Ansible Commands

```bash
# List all hosts in inventory
ansible -i inventory/hosts all --list-hosts

# Check syntax
ansible-playbook site.yml --syntax-check

# Run with increased verbosity
ansible-playbook site.yml -vvv

# Run specific tags
ansible-playbook site.yml -t security

# Skip specific tags
ansible-playbook site.yml --skip-tags monitoring
```

## Next Steps

- Deploy to AWS EC2 instances with dynamic inventory
- Add Vault for secrets management
- Integrate with CI/CD pipeline (GitHub Actions → Ansible)
- Create custom Ansible modules
- Implement Ansible Tower for centralized management
- Add compliance checks with Ansible Compliance

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Pre-built roles
