#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install nginx
apt-get install -y nginx

# Create custom index page
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4/)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>DevOps ALB Deployment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        h1 { color: #333; }
        .info { margin: 10px 0; font-size: 16px; }
        .success { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="success">✓ Application successfully deployed!</h1>
        <p>This instance is running behind the Application Load Balancer.</p>
        <div class="info"><strong>Instance ID:</strong> $INSTANCE_ID</div>
        <div class="info"><strong>Hostname:</strong> $HOSTNAME</div>
        <div class="info"><strong>Private IP:</strong> $PRIVATE_IP</div>
        <div class="info"><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</div>
        <hr>
        <p><small>Served by DevOps ALB Infrastructure - Terraform deployment</small></p>
    </div>
</body>
</html>
EOF

# Start nginx
systemctl start nginx
systemctl enable nginx

# Log deployment completion
echo "Deployment completed on $(date)" >> /var/log/user_data.log
