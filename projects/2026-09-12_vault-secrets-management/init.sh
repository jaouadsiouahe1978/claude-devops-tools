#!/bin/bash

# Vault Initialization Script
# This script initializes Vault, unseals it, and configures basic secrets

set -e

VAULT_ADDR="http://localhost:8200"
VAULT_TOKEN="myroot"
KEYS_FILE="/vault/data/init_keys.json"

echo "=== Vault Initialization Script ==="
echo ""

# Wait for Vault to be ready
echo "[1/7] Waiting for Vault to be ready..."
for i in {1..30}; do
    if curl -s "$VAULT_ADDR/v1/sys/health" > /dev/null 2>&1; then
        echo "✓ Vault is ready!"
        break
    fi
    echo "  Attempt $i/30..."
    sleep 2
done

# Check if already initialized
echo "[2/7] Checking if Vault is already initialized..."
INIT_STATUS=$(curl -s "$VAULT_ADDR/v1/sys/init" | grep -o '"initialized":[^,}]*' | cut -d: -f2)

if [ "$INIT_STATUS" = "true" ]; then
    echo "✓ Vault is already initialized"
else
    echo "Initializing Vault..."
    curl -X POST "$VAULT_ADDR/v1/sys/init" \
        -d '{
            "shares": 1,
            "threshold": 1,
            "pgp_keys": []
        }' > "$KEYS_FILE"
    echo "✓ Vault initialized"
fi

# Unseal Vault
echo "[3/7] Unsealing Vault..."
UNSEAL_KEY=$(cat "$KEYS_FILE" | grep -o '"keys":\[\s*"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$UNSEAL_KEY" ]; then
    curl -X POST "$VAULT_ADDR/v1/sys/unseal" \
        -d "{\"key\": \"$UNSEAL_KEY\"}" > /dev/null 2>&1
    echo "✓ Vault unsealed"
fi

# Wait a bit for Vault to fully start
sleep 2

# Export Vault token
export VAULT_TOKEN="myroot"
export VAULT_ADDR="http://localhost:8200"

# Enable required secret engines
echo "[4/7] Enabling secret engines..."

# KV v2 secrets engine
curl -X POST "$VAULT_ADDR/v1/sys/mounts/secret" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -d '{"type": "kv", "options": {"version": "2"}}' 2>/dev/null || echo "  (KV engine already enabled or error)"

# Database secrets engine
curl -X POST "$VAULT_ADDR/v1/sys/mounts/database" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -d '{"type": "database"}' 2>/dev/null || echo "  (Database engine already enabled)"

echo "✓ Secret engines enabled"

# Create sample static secrets
echo "[5/7] Creating sample static secrets..."

curl -X POST "$VAULT_ADDR/v1/kv/data/secret/database" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "data": {
            "host": "postgres",
            "port": "5432",
            "database": "vault_demo",
            "username": "vaultadmin",
            "password": "vaultpass123"
        }
    }' > /dev/null

curl -X POST "$VAULT_ADDR/v1/kv/data/secret/api" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "data": {
            "api_key": "sk-abc123xyz789",
            "api_secret": "secret-key-12345",
            "endpoints": {
                "prod": "https://api.example.com",
                "staging": "https://staging-api.example.com"
            }
        }
    }' > /dev/null

echo "✓ Sample secrets created"

# Create policies
echo "[6/7] Creating sample policies..."

# Read-only policy
curl -X POST "$VAULT_ADDR/v1/sys/policies/acl/readonly" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -d '{
        "policy": "path \"kv/data/secret/*\" { capabilities = [\"read\", \"list\"] }\npath \"database/creds/*\" { capabilities = [\"read\"] }"
    }' > /dev/null

# Admin policy
curl -X POST "$VAULT_ADDR/v1/sys/policies/acl/admin" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -d '{
        "policy": "path \"*\" { capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\", \"sudo\"] }"
    }' > /dev/null

echo "✓ Policies created"

# Enable AppRole auth method
echo "[7/7] Enabling AppRole authentication..."

curl -X POST "$VAULT_ADDR/v1/sys/auth/approle" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -d '{"type": "approle"}' 2>/dev/null || echo "  (AppRole already enabled)"

# Create sample AppRole
curl -X POST "$VAULT_ADDR/v1/auth/approle/role/demo-app" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -d '{
        "bind_secret_id": true,
        "secret_id_ttl": "24h",
        "secret_id_num_uses": 0,
        "token_ttl": "1h",
        "token_max_ttl": "24h",
        "policies": ["readonly"]
    }' > /dev/null

echo "✓ AppRole configured"

echo ""
echo "=== Vault Initialization Complete ==="
echo ""
echo "Next steps:"
echo "1. Login to Vault:"
echo "   export VAULT_ADDR='http://localhost:8200'"
echo "   export VAULT_TOKEN='myroot'"
echo "   vault status"
echo ""
echo "2. Read a secret:"
echo "   vault kv get secret/database"
echo ""
echo "3. Get AppRole credentials:"
echo "   vault read auth/approle/role/demo-app/role-id"
echo "   vault generate auth/approle/role/demo-app/secret-id"
echo ""
echo "4. Configure PostgreSQL dynamic credentials (see examples/)"
echo ""
echo "Root Token: myroot"
echo "Unseal Key: $UNSEAL_KEY"
