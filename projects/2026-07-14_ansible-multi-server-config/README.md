# Ansible Multi-Server Configuration Management

## 📋 Description

Deploy and configure a complete infrastructure with multiple roles using Ansible :
- **Common Role** : Install base packages, configure timezone, manage SSH keys, update system
- **Web Server Role** : Install Nginx, configure virtual hosts, enable HTTPS ready setup
- **Database Role** : Install PostgreSQL, create databases and users, configure backups

This project teaches you how to structure Ansible playbooks with reusable roles, manage inventory, use handlers for service management, and deploy to multiple environments.

## 🎯 Objectives

- Master Ansible role structure and best practices
- Configure multiple servers simultaneously with idempotent tasks
- Manage secrets with Ansible vault (basic setup)
- Use handlers for efficient service restarts
- Create an inventaire for dev/staging/prod environments
- Deploy configuration changes with minimal downtime

## 🛠️ Technologies

- **Ansible** 2.9+ (config management)
- **Python** 3.6+ (Ansible requirement)
- **SSH** (remote connectivity)
- **Docker** (optional, for testing with containers)

## 📋 Prerequisites

```bash
# Install Ansible
pip install ansible>=2.9

# Install required collections
ansible-galaxy install -r requirements.yml

# SSH access to target servers
ssh-keygen -t ed25519 -f ~/.ssh/ansible_key
```

## 🚀 Quick Start

### 1. Setup your inventory

```bash
# Edit inventory/production.ini with your server IPs
vi inventory/production.ini
```

### 2. Test connectivity

```bash
ansible all -i inventory/production.ini -m ping
```

### 3. Run the playbook

```bash
# Syntax check
ansible-playbook -i inventory/production.ini playbook.yml --syntax-check

# Dry run (show what would happen)
ansible-playbook -i inventory/production.ini playbook.yml --check

# Execute full deployment
ansible-playbook -i inventory/production.ini playbook.yml -v
```

### 4. Deploy specific roles only

```bash
ansible-playbook -i inventory/production.ini playbook.yml --tags webserver
ansible-playbook -i inventory/production.ini playbook.yml --tags database
```

## 📁 Project Structure

```
.
├── playbook.yml                 # Main playbook
├── requirements.yml             # Ansible Galaxy dependencies
├── ansible.cfg                  # Ansible configuration
├── inventory/
│   ├── production.ini          # Production servers
│   ├── staging.ini             # Staging environment
│   └── dev.ini                 # Development with Docker containers
├── roles/
│   ├── common/                 # Base configuration
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/sshd_config.j2
│   │   └── defaults/main.yml
│   ├── webserver/              # Nginx setup
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/nginx.conf.j2
│   │   └── defaults/main.yml
│   └── database/               # PostgreSQL setup
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       ├── templates/postgresql.conf.j2
│       └── defaults/main.yml
├── group_vars/
│   ├── all.yml                # Variables for all hosts
│   ├── webservers.yml         # Variables for web server group
│   └── databases.yml          # Variables for database group
├── host_vars/
│   └── server1.example.com.yml # Host-specific variables
└── Makefile                    # Common commands
```

## 📚 What You Learn

### Ansible Concepts
- **Playbooks** : Declarative infrastructure as code
- **Roles** : Modular, reusable configuration blocks
- **Handlers** : Event-driven service management (restart on change)
- **Jinja2 Templates** : Dynamic configuration files
- **Variables** : Defaults, group vars, host vars, and facts
- **Tags** : Selective role/task execution
- **Handlers** : Efficient service restarts (only when changed)

### DevOps Skills
- Infrastructure automation and orchestration
- Idempotent configuration (safe to run multiple times)
- Secrets management with Ansible Vault
- Environment-specific configurations (dev/staging/prod)
- Monitoring configuration through playbooks
- Zero-downtime deployments with rolling updates

## 🔧 Hands-On Exercises

### Exercise 1 : Add a new package to common role
Edit `roles/common/defaults/main.yml` and add a package, then run :
```bash
ansible-playbook -i inventory/production.ini playbook.yml --tags common
```

### Exercise 2 : Create a new virtual host
Add a Jinja2 template in `roles/webserver/templates/` for a new site, then deploy.

### Exercise 3 : Setup automated backups
Add a cron task in the database role to backup PostgreSQL daily.

### Exercise 4 : Use Ansible Vault for secrets
```bash
ansible-vault create group_vars/databases/vault.yml
ansible-playbook -i inventory/production.ini playbook.yml --ask-vault-pass
```

## ⚡ Running with Docker (for testing)

```bash
# Create test containers
docker-compose up -d

# Get container IPs
docker-compose exec server1 hostname -I

# Update inventory/dev.ini with container IPs
# Run against Docker containers
ansible-playbook -i inventory/dev.ini playbook.yml -u root -k
```

## 🎓 Learning Path

1. **Day 1** : Understand playbook structure and roles
2. **Day 2** : Deploy the common role and verify idempotence
3. **Day 3** : Add web server role with custom configurations
4. **Day 4** : Configure database role with backups
5. **Day 5** : Implement secrets management with Vault

## 📖 Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/)
- [Galaxy - Community Roles](https://galaxy.ansible.com/)

## 🐛 Troubleshooting

**SSH connection fails:**
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/ansible_key
chmod 644 ~/.ssh/ansible_key.pub

# Test SSH connection
ssh -i ~/.ssh/ansible_key user@target-server
```

**Playbook syntax errors:**
```bash
ansible-playbook playbook.yml --syntax-check
```

**Debug task execution:**
```bash
ansible-playbook playbook.yml -vvv
```

## 📝 License

This project is part of Jaouad's DevOps learning journey.
