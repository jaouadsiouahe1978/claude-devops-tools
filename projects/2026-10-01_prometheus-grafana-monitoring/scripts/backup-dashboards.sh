#!/bin/bash

echo "💾 Backing up Grafana Dashboards..."

BACKUP_DIR="./backups/$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "$BACKUP_DIR"

# Grafana API endpoint
GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASSWORD="admin"

# Function to backup dashboard
backup_dashboard() {
    local dashboard_id=$1
    local dashboard_name=$2

    echo -n "  Backing up: $dashboard_name... "

    curl -s -H "Accept: application/json" \
         -H "Content-Type: application/json" \
         -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
         "$GRAFANA_URL/api/dashboards/db/$dashboard_name" | jq . > "$BACKUP_DIR/$dashboard_name.json"

    if [ $? -eq 0 ]; then
        echo "✅"
    else
        echo "❌"
    fi
}

# Get all dashboards
echo "Fetching dashboard list..."

dashboards=$(curl -s -H "Accept: application/json" \
                   -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
                   "$GRAFANA_URL/api/search?query=&starred=false&limit=1000" | jq -r '.[] | .uid')

count=0
for uid in $dashboards; do
    backup_dashboard "$uid" "$uid"
    ((count++))
done

echo ""
echo "✅ Backed up $count dashboards to: $BACKUP_DIR"
echo ""
echo "To restore, use:"
echo "  curl -X POST -H 'Content-Type: application/json' -d @<backup_file> \\"
echo "    -u admin:admin http://localhost:3000/api/dashboards/db"
