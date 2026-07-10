#!/usr/bin/env python3
"""
Custom Prometheus Exporter
Envoie des métriques applicatives custom
"""

import time
import random
import os
from prometheus_client import start_http_server, Counter, Gauge, Histogram

# Métriques custom
requests_total = Counter(
    'application_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

request_duration_seconds = Histogram(
    'application_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint'],
    buckets=(0.1, 0.5, 1.0, 2.0, 5.0)
)

active_connections = Gauge(
    'application_active_connections',
    'Number of active connections'
)

database_query_time = Gauge(
    'application_database_query_time_seconds',
    'Last database query execution time',
    ['query_type']
)

cache_hits = Counter(
    'application_cache_hits_total',
    'Total cache hits',
    ['cache_name']
)

cache_misses = Counter(
    'application_cache_misses_total',
    'Total cache misses',
    ['cache_name']
)

def simulate_application_metrics():
    """Simule des métriques applicatives réalistes"""
    while True:
        # Requests simulées
        methods = ['GET', 'POST', 'PUT', 'DELETE']
        endpoints = ['/api/users', '/api/products', '/api/orders', '/health']
        statuses = ['200', '201', '400', '404', '500']

        for _ in range(random.randint(1, 5)):
            method = random.choice(methods)
            endpoint = random.choice(endpoints)
            status = random.choice(statuses)
            duration = random.uniform(0.01, 2.0)

            requests_total.labels(method=method, endpoint=endpoint, status=status).inc()
            request_duration_seconds.labels(method=method, endpoint=endpoint).observe(duration)

        # Active connections
        active_connections.set(random.randint(10, 100))

        # Database query times
        query_types = ['select', 'insert', 'update', 'delete']
        for query_type in query_types:
            database_query_time.labels(query_type=query_type).set(random.uniform(0.001, 0.5))

        # Cache performance
        cache_names = ['redis', 'memcached', 'local']
        for cache_name in cache_names:
            hits = random.randint(100, 1000)
            misses = random.randint(10, 200)
            cache_hits.labels(cache_name=cache_name).inc(hits)
            cache_misses.labels(cache_name=cache_name).inc(misses)

        time.sleep(5)

if __name__ == '__main__':
    # Lancer le serveur HTTP Prometheus
    port = int(os.getenv('EXPORTER_PORT', '8888'))
    print(f"Starting custom exporter on port {port}...")
    start_http_server(port)

    # Générer les métriques
    simulate_application_metrics()
