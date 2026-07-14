# Project Summary: Ansible Multi-Server Configuration Management

## 📌 Project Overview

This project demonstrates a production-ready Ansible setup for managing infrastructure across multiple servers. It covers the full lifecycle of infrastructure as code with Ansible: from playbook structure, role organization, inventory management, to deployment strategies.

## 🎯 Key Learning Outcomes

### Ansible Fundamentals
- ✅ Playbook structure and syntax
- ✅ Roles for modular configuration management
- ✅ Inventory management (production, staging, dev environments)
- ✅ Variables precedence and scoping
- ✅ Handlers for efficient service management
- ✅ Jinja2 templating for dynamic configurations
- ✅ Tags for selective execution

### Infrastructure Configuration
- ✅ System base configuration (timezone, SSH, firewall, updates)
- ✅ Nginx web server setup with virtual hosts
- ✅ PostgreSQL database installation and configuration
- ✅ Performance tuning and optimization
- ✅ Automated backup strategies
- ✅ Monitoring and logging setup

### DevOps Practices
- ✅ Idempotent task design (safe to run multiple times)
- ✅ Environment-specific configurations
- ✅ Secrets management with Ansible Vault (setup included)
- ✅ Rolling deployments without downtime
- ✅ Dry-run testing with --check mode
- ✅ Syntax validation before deployment

## 📁 Project Structure

```
2026-07-14_ansible-multi-server-config/
├── playbook.yml                 # Main playbook
├── ansible.cfg                  # Ansible configuration
├── requirements.yml             # Galaxy dependencies
├── Makefile                     # Common commands
├── docker-compose.yml           # Test environment
├── README.md                    # Getting started
├── ADVANCED_USAGE.md            # Advanced topics
├── TROUBLESHOOTING.md           # Common issues
├── inventory/
│   ├── production.ini           # Production servers
│   ├── staging.ini              # Staging environment
│   └── dev.ini                  # Development (Docker)
├── group_vars/
│   ├── all.yml                 # Global variables
│   ├── webservers.yml          # Web server config
│   └── databases.yml           # Database config
├── host_vars/                   # Host-specific variables
└── roles/
    ├── common/                  # Base system configuration
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   ├── templates/
    │   ├── defaults/main.yml
    │   └── vars/.keep
    ├── webserver/               # Nginx setup
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   ├── templates/
    │   ├── defaults/main.yml
    │   └── vars/.keep
    └── database/                # PostgreSQL setup
        ├── tasks/main.yml
        ├── handlers/main.yml
        ├── templates/
        ├── defaults/main.yml
        └── vars/.keep
```

## 🚀 Technologies Used

| Technology | Version | Purpose |
|-----------|---------|---------|
| Ansible | 2.9+ | Orchestration & Configuration Management |
| Python | 3.6+ | Ansible runtime |
| Nginx | Latest | Web server configuration |
| PostgreSQL | 14 | Database installation & config |
| Ubuntu/Debian | 20.04+ | Target OS |
| Docker | Latest | Testing environment |
| Bash | 4.0+ | Scripting (backup automation) |

## 📋 Features Implemented

### Common Role
- System package installation and updates
- Timezone configuration
- NTP (Network Time Protocol) setup
- SSH hardening and security
- Firewall configuration
- Automatic security updates
- User management framework

### Webserver Role
- Nginx installation and configuration
- Virtual host management (via Jinja2 templates)
- SSL/TLS certificate support
- Gzip compression
- Caching strategy
- Performance optimization
- Health check endpoint
- Monitoring status page

### Database Role
- PostgreSQL installation and configuration
- Database and user creation
- Connection pooling setup
- Performance tuning (shared_buffers, work_mem, etc.)
- Backup automation (daily, with retention)
- Replication support (HA ready)
- Comprehensive logging
- Statistics and monitoring

## 🔑 Key Ansible Concepts Demonstrated

### 1. Handlers (Event-driven Actions)
```yaml
- notify: restart nginx  # Task triggers handler
handlers:
  - name: restart nginx  # Handler executed only if changed
```

### 2. Templates (Jinja2)
```jinja2
listen {{ item.listen | default('80') }};
server_name {{ item.server_name | default('_') }};
```

### 3. Conditionals
```yaml
when: inventory_hostname in groups['webservers']
when: ssl_enabled and ansible_os_family == "Debian"
```

### 4. Loops
```yaml
loop: "{{ postgres_databases }}"
with_items: "{{ common_packages }}"
```

### 5. Variables & Facts
```yaml
- set_fact: my_var={{ some_value }}
- debug: var=ansible_distribution
```

## 🎓 Hands-On Exercises

### Exercise 1: Deploy to Docker Containers
```bash
make docker-up
make docker-test
```

### Exercise 2: Add a New Nginx Site
1. Edit `group_vars/webservers.yml`
2. Add new site to `nginx_sites` list
3. Run: `ansible-playbook playbook.yml --tags webserver --check`

### Exercise 3: Configure Database Backup
1. Enable backup in `group_vars/databases.yml`: `backup_enabled: yes`
2. Run: `ansible-playbook playbook.yml --tags database`

### Exercise 4: Implement Secrets Management
```bash
ansible-vault create group_vars/databases/vault.yml
# Add: postgres_admin_password: "secret123"
ansible-playbook playbook.yml --ask-vault-pass
```

### Exercise 5: Rolling Deployment
Edit playbook to deploy in stages without downtime.

## ⚡ Quick Commands

```bash
# Syntax validation
make syntax-check

# Dry-run
make check

# Connectivity test
make ping

# Full deployment
make deploy

# Specific role
make test-webserver

# Docker testing
make docker-up && make docker-test

# Debug specific host
ansible server1 -i inventory/production.ini -m setup
```

## 🔒 Security Best Practices

1. **Vault for Secrets**: Encrypted password storage
2. **SSH Hardening**: Disable root login, use keys only
3. **Firewall Rules**: UFW configuration for port access
4. **Sudo Configuration**: Privilege escalation controls
5. **Update Strategy**: Automatic security patches
6. **Fact Validation**: Only execute on Debian-based systems

## 📊 Deployment Strategy

### Environment Progression
```
Development (Docker) → Staging (Test) → Production
```

### Validation Steps
1. Syntax check (`--syntax-check`)
2. Dry-run (`--check`)
3. Connectivity test (`ansible ... -m ping`)
4. Deploy with verbosity (`-v`)
5. Verify in smoke tests

## 🎯 Next Steps for Learning

1. **Week 1**: Master basic playbook execution
2. **Week 2**: Implement custom roles for your services
3. **Week 3**: Set up Vault and manage secrets
4. **Week 4**: Deploy to real servers with rolling updates
5. **Week 5**: Integrate with CI/CD pipeline

## 📚 Resources

- [Ansible Official Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/)
- [Jinja2 Template Engine](https://jinja.palletsprojects.com/)
- [Galaxy Community Roles](https://galaxy.ansible.com/)

## 🐛 Common Troubleshooting

| Issue | Solution |
|-------|----------|
| SSH connection refused | Check `ansible_user`, `ansible_host`, and SSH key permissions |
| Module not found | Install required Python packages: `python3-psycopg2`, etc. |
| Syntax errors | Run `ansible-playbook ... --syntax-check` |
| Variable undefined | Check variable precedence and scope |
| Task not idempotent | Use proper modules instead of shell commands |

## ✅ Completion Checklist

- [x] Playbook structure and organization
- [x] Common role implementation
- [x] Webserver role with Nginx
- [x] Database role with PostgreSQL
- [x] Inventory for multiple environments
- [x] Variable organization (group_vars, host_vars)
- [x] Handlers for service management
- [x] Jinja2 templates
- [x] Docker testing environment
- [x] Documentation and troubleshooting guides
- [x] Makefile for quick commands
- [x] Advanced usage guide
- [x] Backup automation

## 📝 Notes for Jaouad

This project teaches you how to scale from managing one server to hundreds. Key takeaways:

1. **Roles are reusable**: Write once, use on thousands of servers
2. **Variables enable flexibility**: Same playbook for dev/staging/prod
3. **Handlers are efficient**: Services restart only when config changes
4. **Idempotence is key**: Safe to run multiple times without breaking things
5. **Templates enable customization**: Dynamic configuration based on variables

This is the foundation for being an effective DevOps/SRE engineer!

---

**Created**: 2026-07-14  
**Technology**: Ansible 2.9+  
**Difficulty**: Intermediate  
**Time to Complete**: 4-6 hours
