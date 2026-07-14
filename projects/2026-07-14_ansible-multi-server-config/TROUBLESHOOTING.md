# Ansible Troubleshooting Guide

## Common Issues and Solutions

### 1. SSH Connection Issues

**Problem**: `"failed to connect to the host via ssh"`

**Solutions**:
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/ansible_key
chmod 644 ~/.ssh/ansible_key.pub

# Test SSH connection directly
ssh -i ~/.ssh/ansible_key -v ubuntu@server1.example.com

# Check ansible.cfg SSH settings
grep -A5 "\[ssh_connection\]" ansible.cfg

# Add SSH key to ssh-agent
ssh-agent bash
ssh-add ~/.ssh/ansible_key
```

### 2. Host Key Verification Failed

**Problem**: `"Host key verification failed"`

**Solution**:
```bash
# Disable host key checking (use with caution)
# Add to ansible.cfg
[defaults]
host_key_checking = False

# Or per-command
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yml

# Or add manually to known_hosts
ssh-keyscan -H server1.example.com >> ~/.ssh/known_hosts
```

### 3. Privilege Escalation Issues

**Problem**: `"failed to set permissions on the directory ... Permission denied"`

**Solution**:
```bash
# Check sudo configuration on remote host
ansible all -i inventory/production.ini -m command -a "sudoers -l"

# Add to sudoers if needed (on remote host)
sudo visudo
# Add: ubuntu ALL=(ALL) NOPASSWD: ALL

# Run playbook with become
ansible-playbook playbook.yml --become --ask-become-pass
```

### 4. Module Not Found

**Problem**: `"No module named 'psycopg2'"`

**Solution**:
```bash
# Install missing Python modules on remote hosts
ansible all -i inventory/production.ini -m apt -a "name=python3-psycopg2 state=present" --become

# Or in playbook
- name: Install Python dependencies
  apt:
    name: python3-psycopg2
    state: present
```

### 5. Syntax Errors

**Problem**: `"ERROR! Unexpected end of file"`

**Solution**:
```bash
# Check YAML syntax
ansible-playbook playbook.yml --syntax-check

# Validate specific file
python3 -m yaml /path/to/file.yml

# Common issues:
# - Incorrect indentation (use spaces, not tabs)
# - Missing colons after keys
# - Unclosed quotes or brackets
```

### 6. Variable Not Defined

**Problem**: `"undefined variable 'my_var'"`

**Solution**:
```bash
# Check variable values
ansible-playbook playbook.yml -e "my_var=value" -v

# Display all facts
ansible hostname -i inventory/production.ini -m setup

# Debug variables
- debug:
    var: my_var

# Set default value
{{ my_var | default('default_value') }}
```

### 7. Changed vs OK Status

**Problem**: Task shows as "changed" every time (not idempotent)

**Solution**:
```bash
# Use proper comparison operators
- name: Example - correct way
  lineinfile:
    path: /etc/file
    regexp: '^my_setting='
    line: 'my_setting=value'

# Avoid shell commands that always report changed
# WRONG:
- shell: echo "something" > /tmp/file

# RIGHT:
- copy:
    content: "something"
    dest: /tmp/file
```

### 8. Timeout Issues

**Problem**: `"timeout waiting for ssh"`

**Solution**:
```bash
# Increase timeout in ansible.cfg
[defaults]
timeout = 30

# In ssh_connection
[ssh_connection]
ssh_args = -o ConnectTimeout=30 -o StrictHostKeyChecking=no
```

### 9. Gathering Facts Slow

**Problem**: Playbook takes too long on first run

**Solution**:
```bash
# Enable fact caching
[defaults]
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400

# Or skip fact gathering if not needed
- hosts: all
  gather_facts: no
```

### 10. Role Not Found

**Problem**: `"ERROR! the role 'common' was not found"`

**Solution**:
```bash
# Check roles path in ansible.cfg
[defaults]
roles_path = ./roles

# Ensure role directory exists
ls -la roles/common/

# If role is at different location
ansible-playbook playbook.yml -e ansible_user_role_path=/path/to/roles
```

## Debugging Strategies

### Enable maximum verbosity:
```bash
ansible-playbook playbook.yml -vvv
```

### Use debug module:
```yaml
- name: Debug task
  debug:
    msg: |
      Variable value: {{ my_var }}
      Task status: {{ ansible_facts['tasks'] }}
```

### Check remote state:
```bash
# Connect to remote host and check manually
ansible server1 -i inventory/production.ini -m command -a "ls -la /etc/nginx/sites-enabled/"
```

### Test specific role:
```bash
ansible-playbook playbook.yml --tags common -v
```

### Dry-run (check mode):
```bash
ansible-playbook playbook.yml --check
```

### Display running tasks:
```bash
# Add to playbook
- name: Show running task
  debug:
    msg: "Current task: {{ ansible_current_task }}"
```

## Log Analysis

### Check Ansible logs:
```bash
# Set log file in ansible.cfg
[defaults]
log_path = ./ansible.log

# View logs
tail -f ansible.log
```

### Check system logs on remote:
```bash
# Syslog
ansible server1 -i inventory/production.ini -m command -a "tail -50 /var/log/syslog"

# Auth logs
ansible server1 -i inventory/production.ini -m command -a "tail -50 /var/log/auth.log"
```

## Performance Issues

### Identify slow tasks:
```bash
# Add timing to callback
# In ansible.cfg
[defaults]
callback_whitelist = profile_tasks, timer

# Run playbook
ansible-playbook playbook.yml
```

### Optimize:
```bash
# Increase forks
[defaults]
forks = 10

# Enable SSH pipelining
[ssh_connection]
pipelining = True

# Reduce fact gathering
gather_subset = network,hardware,virtual
```

## Testing and Validation

```bash
# Syntax check
ansible-playbook playbook.yml --syntax-check

# Check with specific inventory
ansible-playbook -i inventory/dev.ini playbook.yml --check

# List tasks without running
ansible-playbook playbook.yml --list-tasks

# List hosts affected
ansible-playbook -i inventory/production.ini playbook.yml --list-hosts
```
