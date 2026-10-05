#!/bin/bash

echo "🔍 Testing Metrics Collection..."
echo ""

# Test Prometheus
echo "1️⃣  Prometheus Health:"
curl -s http://localhost:9090/api/v1/status/runtimeinfo | jq '.data.goroutines' || echo "❌ Prometheus not accessible"

# Test Targets
echo ""
echo "2️⃣  Scrape Targets:"
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, instance: .labels.instance, health: .health}'

# Test Prometheus Metrics
echo ""
echo "3️⃣  Sample Prometheus Metrics:"
echo ""
echo "Metric: up (Instance Health)"
curl -s 'http://localhost:9090/api/v1/query?query=up' | jq '.data.result[] | {job: .metric.job, instance: .metric.instance, value: .value[1]}'

echo ""
echo "Metric: node_memory_MemAvailable_bytes (Available Memory)"
curl -s 'http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes' | jq '.data.result[0] | {instance: .metric.instance, available_gb: (.value[1] | tonumber | . / (1024^3) | tostring + " GB")}'

echo ""
echo "Metric: node_cpu_seconds_total (CPU Time)"
curl -s 'http://localhost:9090/api/v1/query?query=increase(node_cpu_seconds_total{mode="user"}[5m])' | jq '.data.result[0]' || echo "❌ No data yet"

# Test node-exporter directly
echo ""
echo "4️⃣  node-exporter Metrics (sample):"
curl -s http://localhost:9100/metrics | grep -E "^node_memory_MemAvailable_bytes|^node_cpu_seconds_total" | head -5

# Test cAdvisor
echo ""
echo "5️⃣  cAdvisor Container Metrics (sample):"
curl -s http://localhost:8080/metrics | grep "container_memory_usage_bytes" | head -3

# Test PostgreSQL metrics
echo ""
echo "6️⃣  PostgreSQL Exporter Metrics (sample):"
curl -s http://localhost:9187/metrics | grep "pg_stat" | head -3

# Test Nginx metrics
echo ""
echo "7️⃣  Nginx Exporter Metrics (sample):"
curl -s http://localhost:4040/metrics | grep -E "^nginx_" | head -5

echo ""
echo "✅ Metrics test complete!"
