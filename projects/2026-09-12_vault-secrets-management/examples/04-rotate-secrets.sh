#!/bin/bash

# Secret Rotation Example
# Demonstrates rotating database root password and managing secret versions

set -e

VAULT_ADDR="http://localhost:8200"
VAULT_TOKEN="myroot"

echo "=== Secret Rotation & Versioning Example ==="
echo ""
echo "This example shows how to:"
echo "1. Rotate database root password"
echo "2. Access secret versions"
echo "3. Implement a rotation policy"
echo ""

# Step 1: View current database config
echo "[Step 1] Viewing current database configuration..."
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/database/config/postgresql" | jq '.data'
echo ""

# Step 2: Rotate the database root password
echo "[Step 2] Rotating database root password..."
echo "⚠ This changes the password that Vault uses to connect"
echo ""

ROTATION_RESULT=$(curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/database/rotate-root/postgresql")

echo "Rotation result:"
echo "$ROTATION_RESULT" | jq '.'
echo ""

# Step 3: View secret metadata and all versions
echo "[Step 3] Viewing secret versions for database credentials..."
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/metadata/secret/database" | jq '.data.versions'
echo ""

# Step 4: Read a specific version of a secret
echo "[Step 4] Reading specific version of secret..."
echo "Getting version 1:"
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/data/secret/database?version=1" | jq '.data.data'
echo ""

# Step 5: Update a secret and create a new version
echo "[Step 5] Updating API secret (creates new version)..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "data": {
            "api_key": "sk-new123xyz789",
            "api_secret": "secret-key-new-12345",
            "endpoints": {
                "prod": "https://api.example.com",
                "staging": "https://staging-api.example.com"
            },
            "rate_limit": "2000/minute"
        }
    }' \
    "$VAULT_ADDR/v1/kv/data/secret/api" > /dev/null

echo "✓ Secret updated (new version created)"
echo ""

# Step 6: View updated metadata
echo "[Step 6] Viewing updated secret metadata..."
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/metadata/secret/api" | jq '.data'
echo ""

# Step 7: Configure automatic secret rotation (example)
echo "[Step 7] Secret Rotation Strategy Example..."
echo ""
echo "In production, implement rotation via:"
echo ""
echo "1. Scheduled Task (cron/kubernetes)"
echo "   */24 * * * * vault write -force database/rotate-root/postgresql"
echo ""
echo "2. Ansible Playbook"
echo "   - name: Rotate Vault secrets"
echo "     command: vault write -force database/rotate-root/postgresql"
echo "     environment:"
echo "       VAULT_ADDR: https://vault.prod"
echo "       VAULT_TOKEN: s.xxxxx"
echo ""
echo "3. Kubernetes CronJob"
echo "   apiVersion: batch/v1"
echo "   kind: CronJob"
echo "   metadata:"
echo "     name: vault-rotation"
echo "   spec:"
echo "     schedule: \"0 2 * * *\"  # 2 AM daily"
echo "     jobTemplate:"
echo "       spec:"
echo "         template:"
echo "           spec:"
echo "             containers:"
echo "             - name: vault-rotate"
echo "               image: vault:latest"
echo "               command:"
echo "               - /bin/sh"
echo "               - -c"
echo "               - vault write -force database/rotate-root/postgresql"
echo ""

# Step 8: Create a retention policy
echo "[Step 8] Implementing Version Retention..."
echo ""
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "max_versions": 10,
        "cas_required": false
    }' \
    "$VAULT_ADDR/v1/kv/config" > /dev/null

echo "✓ Configured to keep last 10 versions of all secrets"
echo ""

# Step 9: Audit log
echo "[Step 9] Auditing secret access..."
curl -s -X LIST -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/sys/audit" | jq '.data'
echo ""

echo "[Example Complete]"
echo ""
echo "Best Practices for Secret Rotation:"
echo "✓ Rotate credentials on a regular schedule (daily/weekly)"
echo "✓ Always keep multiple versions for rollback"
echo "✓ Log all rotation events for compliance"
echo "✓ Test rotation in dev/staging first"
echo "✓ Notify when rotation fails"
echo "✓ Use automation (don't do it manually)"
