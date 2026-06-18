#!/bin/bash
set -e

TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/..terraform" 2>/dev/null && pwd)" || TF_DIR="./terraform"

echo "⚠️  WARNING: This will DELETE all infrastructure!"
read -p "Type 'yes' to confirm: " -r CONFIRM
[[ "$CONFIRM" == "yes" ]] || exit 0

cd "$TF_DIR"
echo "🗑️  Destroying..."
terraform destroy

echo "✅ Destroyed"
