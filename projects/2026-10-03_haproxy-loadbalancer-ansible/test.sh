#!/bin/bash

set -e

echo "================================================"
echo "Testing HAProxy Load Balancer Setup"
echo "================================================"

# Extract LB IP from inventory
LB_IP=$(grep "lb-server" inventory/hosts.ini | grep ansible_host | awk -F= '{print $2}' | awk '{print $1}')
LB_PORT=80
STATS_PORT=8404

echo "[*] Load Balancer IP: $LB_IP"
echo ""

# Test HAProxy connectivity
echo "[*] Testing HAProxy connectivity..."
if curl -s "http://$LB_IP:$LB_PORT/" > /dev/null 2>&1; then
    echo "[✓] HAProxy is responding"
else
    echo "[✗] HAProxy is NOT responding"
    exit 1
fi
echo ""

# Test HAProxy Stats
echo "[*] Testing HAProxy Stats interface..."
if curl -s "http://$LB_IP:$STATS_PORT/stats" > /dev/null 2>&1; then
    echo "[✓] HAProxy Stats is accessible"
    echo "    URL: http://$LB_IP:$STATS_PORT/stats"
else
    echo "[✗] HAProxy Stats is NOT accessible"
fi
echo ""

# Test load balancing (round-robin)
echo "[*] Testing load balancing (10 requests)..."
declare -A responses
for i in {1..10}; do
    response=$(curl -s "http://$LB_IP:$LB_PORT/" | head -1)
    echo "  [$i] $response"
    responses["$response"]=$((${responses["$response"]:-0} + 1))
done
echo ""

echo "[*] Request distribution:"
for server in "${!responses[@]}"; do
    echo "    $server: ${responses[$server]} requests"
done
echo ""

# Test backend servers directly
echo "[*] Testing backend servers directly..."
BACKEND_IPS=$(grep "web" inventory/hosts.ini | grep ansible_host | awk -F= '{print $2}' | awk '{print $1}')

for ip in $BACKEND_IPS; do
    echo "  Testing $ip:8080/health..."
    if curl -s "http://$ip:8080/health" > /dev/null 2>&1; then
        echo "    [✓] Backend $ip is healthy"
    else
        echo "    [✗] Backend $ip is NOT responding"
    fi
done
echo ""

# Test failover (optional)
echo "[*] Load Balancer Configuration Summary:"
echo "    Algorithm: $(grep "balance" inventory/group_vars/haproxy.yml | awk '{print $NF}')"
echo "    Health Check Interval: 2s"
echo "    Rise: 3 (mark as up after 3 successes)"
echo "    Fall: 2 (mark as down after 2 failures)"
echo ""

echo "[✓] All tests completed!"
echo ""
echo "Next steps:"
echo "1. Monitor HAProxy stats at: http://$LB_IP:$STATS_PORT/stats"
echo "2. Test with: for i in {1..20}; do curl http://$LB_IP/; done"
echo "3. Check logs: ssh admin@$LB_IP 'tail -f /var/log/haproxy/haproxy.log'"
