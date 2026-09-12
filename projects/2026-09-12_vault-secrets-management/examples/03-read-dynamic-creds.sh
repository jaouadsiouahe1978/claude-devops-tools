#!/bin/bash

# Dynamic Credentials Example
# Demonstrates generating temporary database credentials

set -e

VAULT_ADDR="http://localhost:8200"
VAULT_TOKEN="myroot"
DB_HOST="postgres"
DB_PORT="5432"
DB_NAME="vault_demo"
DB_ADMIN="vaultadmin"
DB_PASS="vaultpass123"

echo "=== Dynamic Database Credentials Example ==="
echo ""
echo "This example shows how to:"
echo "1. Configure Vault to manage PostgreSQL credentials"
echo "2. Create roles that auto-generate temporary users"
echo "3. Request temporary credentials that expire automatically"
echo ""

# Step 1: Install PostgreSQL plugin (usually pre-installed)
echo "[Step 1] Verifying PostgreSQL database plugin..."
PLUGINS=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/sys/plugins/catalog/database" | grep -c "postgresql-database-plugin" || echo "0")

if [ "$PLUGINS" -eq "0" ]; then
    echo "⚠ PostgreSQL plugin not in catalog, using built-in"
fi
echo "✓ Ready"
echo ""

# Step 2: Configure connection to PostgreSQL
echo "[Step 2] Configuring Vault connection to PostgreSQL..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"plugin_name\": \"postgresql-database-plugin\",
        \"allowed_roles\": \"readonly,readwrite\",
        \"connection_url\": \"postgresql://{{username}}:{{password}}@${DB_HOST}:${DB_PORT}/${DB_NAME}\",
        \"username\": \"${DB_ADMIN}\",
        \"password\": \"${DB_PASS}\",
        \"verify_connection\": true
    }" \
    "$VAULT_ADDR/v1/database/config/postgresql" > /dev/null

echo "✓ PostgreSQL configured"
echo ""

# Step 3: Create a read-only database role
echo "[Step 3] Creating read-only role..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "db_name": "postgresql",
        "creation_statements": "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '"'"'{{password}}'"'"' VALID UNTIL '"'"'{{expiration}}'"'"'; GRANT CONNECT ON DATABASE vault_demo TO \"{{name}}\"; GRANT USAGE ON SCHEMA public TO \"{{name}}\"; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
        "default_ttl": "1h",
        "max_ttl": "24h"
    }' \
    "$VAULT_ADDR/v1/database/roles/readonly" > /dev/null

echo "✓ Read-only role created (TTL: 1h, Max: 24h)"
echo ""

# Step 4: Create a read-write database role
echo "[Step 4] Creating read-write role..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "db_name": "postgresql",
        "creation_statements": "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '"'"'{{password}}'"'"' VALID UNTIL '"'"'{{expiration}}'"'"'; GRANT CONNECT ON DATABASE vault_demo TO \"{{name}}\"; GRANT USAGE ON SCHEMA public TO \"{{name}}\"; GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\";",
        "default_ttl": "30m",
        "max_ttl": "12h"
    }' \
    "$VAULT_ADDR/v1/database/roles/readwrite" > /dev/null

echo "✓ Read-write role created (TTL: 30m, Max: 12h)"
echo ""

# Step 5: Request temporary read-only credentials
echo "[Step 5] Generating temporary read-only credentials..."
echo ""
CREDS=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/database/creds/readonly")

RO_USER=$(echo "$CREDS" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
RO_PASS=$(echo "$CREDS" | grep -o '"password":"[^"]*"' | cut -d'"' -f4)
RO_TTL=$(echo "$CREDS" | grep -o '"ttl":"[^"]*"' | cut -d'"' -f4)

echo "Generated credentials:"
echo "  Username: $RO_USER"
echo "  Password: $RO_PASS"
echo "  TTL: $RO_TTL (expires in 1 hour)"
echo "  Lease ID: $(echo "$CREDS" | grep -o '"lease_id":"[^"]*"' | cut -d'"' -f4)"
echo ""

# Step 6: Request temporary read-write credentials
echo "[Step 6] Generating temporary read-write credentials..."
echo ""
CREDS=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/database/creds/readwrite")

RW_USER=$(echo "$CREDS" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
RW_PASS=$(echo "$CREDS" | grep -o '"password":"[^"]*"' | cut -d'"' -f4)
RW_TTL=$(echo "$CREDS" | grep -o '"ttl":"[^"]*"' | cut -d'"' -f4)

echo "Generated credentials:"
echo "  Username: $RW_USER"
echo "  Password: $RW_PASS"
echo "  TTL: $RW_TTL (expires in 30 minutes)"
echo ""

# Step 7: Verify the credentials work
echo "[Step 7] Testing credentials (optional)..."
echo ""
echo "To test with psql:"
echo "  psql -h $DB_HOST -U $RO_USER -d $DB_NAME"
echo "  (Enter password: $RO_PASS)"
echo ""

# Step 8: List active credentials
echo "[Step 8] Listing all active credentials..."
curl -s -X LIST -H "X-Vault-Token: $VAULT_TOKEN" \
    "$VAULT_ADDR/v1/database/creds" | jq '.data.keys'
echo ""

echo "[Example Complete]"
echo ""
echo "Key Learnings:"
echo "✓ Temporary users auto-expire (no manual cleanup)"
echo "✓ Each request gets unique credentials"
echo "✓ No shared passwords between apps"
echo "✓ Automatic credential rotation support"
echo "✓ Audit trail of all credential requests"
echo ""
echo "Benefits in production:"
echo "• Reduced blast radius if credentials are leaked"
echo "• Automatic compliance with credential rotation policies"
echo "• No hardcoded passwords in config files"
echo "• Easy to grant app-specific access levels"
