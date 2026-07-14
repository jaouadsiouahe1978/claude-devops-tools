# Advanced Ansible Usage Guide

## Ansible Vault for Secrets Management

### Creating an encrypted vault file:

```bash
# Create a vault file for sensitive data
ansible-vault create group_vars/databases/vault.yml

# Add secrets to the file:
---
postgres_admin_password: "super_secret_password_123"
postgres_users:
  - name: app_user
    password: "app_user_secret_password"
```

### Using vault in playbooks:

```bash
# Deploy with vault password prompt
ansible-playbook playbook.yml --ask-vault-pass

# Deploy with vault password from file
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass

# Deploy with vault ID
ansible-playbook playbook.yml --vault-id prod@prompt
```

### View/Edit vault files:

```bash
ansible-vault view group_vars/databases/vault.yml
ansible-vault edit group_vars/databases/vault.yml
```

## Advanced Inventory Management

### Using dynamic inventory:

```bash
# Create a script that returns JSON
#!/bin/bash
python3 -c "import json; print(json.dumps({...}))"
```

### Inventory patterns:

```bash
# Run on specific hosts
ansible-playbook -i inventory/production.ini playbook.yml -l web1.example.com

# Run on host groups
ansible-playbook -i inventory/production.ini playbook.yml -l webservers

# Run on host range
ansible-playbook -i inventory/production.ini playbook.yml -l "server[1:3]"

# Exclude hosts
ansible-playbook -i inventory/production.ini playbook.yml -l "all:!server1"
```

## Handlers and Notifiers

Handlers are triggered only when tasks change. Best practice example:

```yaml
- name: Install package
  apt:
    name: nginx
  notify: restart nginx

- name: Restart nginx
  systemd:
    name: nginx
    state: restarted
  listen: "restart nginx"  # Can be triggered by multiple tasks
```

## Variables Precedence (High to Low)

1. Command line variables (-e)
2. Play variables (vars)
3. Registered variables
4. Host variables (host_vars/)
5. Group variables (group_vars/)
6. Role variables (roles/*/vars/)
7. Role defaults (roles/*/defaults/)

Example:

```bash
# Command line overrides everything
ansible-playbook playbook.yml -e "nginx_worker_processes=4"
```

## Debugging and Troubleshooting

### Enable verbose output:

```bash
-v   # Minimal verbosity
-vv  # Medium verbosity
-vvv # Maximum verbosity (debug)
```

### Debug module:

```yaml
- name: Display variable values
  debug:
    var: my_variable

- name: Display custom message
  debug:
    msg: "{{ my_variable }} - Custom message"
```

### Register and debug:

```yaml
- name: Run command
  command: uname -a
  register: system_info

- name: Display result
  debug:
    var: system_info
```

### Gather facts:

```bash
# Show all facts for a host
ansible hostname -i inventory/production.ini -m setup

# Show specific fact
ansible hostname -i inventory/production.ini -m setup -a "filter=ansible_os_family"
```

## Performance Optimization

### 1. Increase forks (parallel execution):

```ini
# In ansible.cfg
[defaults]
forks = 10  # Default is 5
```

### 2. Enable SSH pipelining:

```ini
[ssh_connection]
pipelining = True
```

### 3. Use fact caching:

```ini
[defaults]
fact_caching = jsonfile
fact_caching_connection = /var/tmp/ansible_facts
fact_caching_timeout = 86400
```

### 4. Skip fact gathering when not needed:

```yaml
- name: Quick playbook
  hosts: all
  gather_facts: no  # Skip gathering facts
```

## Rolling Deployments

Deploy to servers in serial batches:

```yaml
- name: Deploy in rolling fashion
  hosts: webservers
  serial: 2  # Update 2 servers at a time
  
  tasks:
    - name: Deploy application
      # ... your deployment tasks
```

## Creating Reusable Roles

### Best practices:

```
roles/
  my_role/
    tasks/
      main.yml        # Must exist
    handlers/
      main.yml        # Optional
    templates/
      app.conf.j2     # Jinja2 templates
    files/
      key.pub         # Static files
    defaults/
      main.yml        # Default variables (lowest priority)
    vars/
      main.yml        # Role variables
    meta/
      main.yml        # Role dependencies
    README.md         # Documentation
```

### Role dependencies:

```yaml
# roles/my_role/meta/main.yml
dependencies:
  - role: common
  - role: geerlingguy.java
```

## Ansible Galaxy

### Install roles from Galaxy:

```bash
ansible-galaxy install geerlingguy.nginx

# Install specific version
ansible-galaxy install geerlingguy.nginx,3.9.0

# Install from requirements.yml
ansible-galaxy install -r requirements.yml
```

## CI/CD Integration

### GitHub Actions example:

```yaml
name: Deploy with Ansible
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Ansible
        run: pip install ansible
      - name: Deploy
        run: ansible-playbook playbook.yml -i inventory/production.ini
        env:
          VAULT_PASSWORD: ${{ secrets.VAULT_PASSWORD }}
```

## Best Practices

1. **Always use tags** for selective execution
2. **Idempotence** - tasks should be safe to run multiple times
3. **Use handlers** for efficient service restarts
4. **Separate data from playbooks** - use variables and vault
5. **Version control** everything except secrets
6. **Use roles** for reusability
7. **Test playbooks** with --check and --syntax-check
8. **Document your playbooks** with comments and README
9. **Use meaningful names** for tasks and handlers
10. **Keep roles focused** - one responsibility per role
