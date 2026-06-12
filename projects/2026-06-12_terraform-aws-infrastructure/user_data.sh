#!/bin/bash
set -e

# Logs
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting instance setup ==="
echo "Environment: ${environment}"
echo "Database Host: ${db_host}"

# Update system
apt-get update
apt-get upgrade -y

# Install dependencies
apt-get install -y \
  curl \
  wget \
  git \
  htop \
  net-tools \
  postgresql-client \
  python3-pip \
  python3-venv

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Create a simple health check endpoint
cat > app.py << 'APPEOF'
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os

class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                'status': 'healthy',
                'environment': os.environ.get('ENV', 'unknown'),
                'hostname': os.uname()[1]
            }
            self.wfile.write(json.dumps(response).encode())
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK')
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        print(f"[{self.client_address[0]}] {format % args}")

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 80), HealthCheckHandler)
    print('Starting web server on port 80...')
    server.serve_forever()
APPEOF

# Create systemd service
cat > /etc/systemd/system/app.service << 'SVCEOF'
[Unit]
Description=DevOps Training Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/app
Environment="ENV=${environment}"
Environment="DB_HOST=${db_host}"
Environment="DB_NAME=${db_name}"
Environment="DB_USER=${db_user}"
ExecStart=/usr/bin/python3 /opt/app/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SVCEOF

# Enable and start service
systemctl daemon-reload
systemctl enable app
systemctl start app

echo "=== Instance setup completed ==="
