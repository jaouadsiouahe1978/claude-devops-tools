#!/usr/bin/env python3
import requests
import time

while True:
    r = requests.get('http://localhost:8000/health')
    print(f'Status: {r.status_code}')
    time.sleep(5)
