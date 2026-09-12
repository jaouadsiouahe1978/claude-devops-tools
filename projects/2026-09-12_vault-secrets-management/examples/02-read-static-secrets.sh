#!/bin/bash

# Static Secrets Example
# Demonstrates reading and managing static secrets in Vault

set -e

VAULT_ADDR="http://localhost:8200"
VAULT_TOKEN="myroot"

echo "=== Static Secrets Management Example ==="
echo ""

# Read database credentials
echo "[1] Reading database credentials..."
echo ""
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/data/secret/database" | jq '.data.data'
echo ""

# Read API credentials
echo "[2] Reading API credentials..."
echo ""
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/data/secret/api" | jq '.data.data'
echo ""

# Create a new secret
echo "[3] Creating a new secret..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "data": {
            "webhook_url": "https://hooks.slack.com/services/...",
            "webhook_channel": "#alerts"
        }
    }' \
    "$VAULT_ADDR/v1/kv/data/secret/webhooks" | jq '.data'
echo "✓ Secret created at secret/webhooks"
echo ""

# List all secrets
echo "[4] Listing all secrets in secret/ path..."
curl -s -X LIST -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/metadata/secret" | jq '.data.keys'
echo ""

# Update a secret (add new field)
echo "[5] Updating API secret with new field..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "data": {
            "api_key": "sk-abc123xyz789",
            "api_secret": "secret-key-12345",
            "endpoints": {
                "prod": "https://api.example.com",
                "staging": "https://staging-api.example.com"
            },
            "rate_limit": "1000/minute"
        }
    }' \
    "$VAULT_ADDR/v1/kv/data/secret/api" > /dev/null
echo "✓ Secret updated"
echo ""

# Read specific field
echo "[6] Reading specific field from secret..."
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/data/secret/api" | jq '.data.data.endpoints.prod'
echo ""

# Get secret metadata (versions, etc)
echo "[7] Viewing secret metadata and versions..."
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/metadata/secret/api" | jq '.data'
echo ""

# Delete a secret (soft delete, keeps history)
echo "[8] Soft-deleting a secret..."
curl -s -X DELETE -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/kv/data/secret/webhooks" > /dev/null
echo "✓ Secret deleted (can be restored)"
echo ""

# Permanently delete (destroy)
echo "[9] Permanently destroying secret versions..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -d '{"versions": [1]}' \
    "$VAULT_ADDR/v1/kv/destroy/secret/webhooks" > /dev/null
echo "✓ Specific versions destroyed (permanent)"
echo ""

echo "[Example Complete]"
echo "You've learned:"
echo "✓ Create, read, update secrets"
echo "✓ List secrets"
echo "✓ Manage secret versions"
echo "✓ Soft delete vs permanent destroy"
