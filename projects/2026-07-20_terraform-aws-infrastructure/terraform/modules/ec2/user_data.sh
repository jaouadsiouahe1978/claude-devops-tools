#!/bin/bash
set -e

# Update system
yum update -y
yum install -y httpd mysql

# Start Apache
systemctl start httpd
systemctl enable httpd

# Create a simple health check page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Lab - Terraform AWS Infrastructure</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .success { color: green; }
        .info { background-color: #f0f0f0; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="success">✓ DevOps Lab - Terraform Infrastructure</h1>
        <p>This instance has been successfully deployed using Terraform!</p>

        <div class="info">
            <h2>System Information</h2>
            <p><strong>Hostname:</strong> <span id="hostname"></span></p>
            <p><strong>OS:</strong> Amazon Linux 2</p>
            <p><strong>Instance Type:</strong> t3.micro</p>
        </div>

        <div class="info">
            <h2>What You've Learned</h2>
            <ul>
                <li>Infrastructure as Code (IaC) with Terraform</li>
                <li>AWS VPC, EC2, RDS deployment</li>
                <li>Terraform modules for code organization</li>
                <li>CloudWatch monitoring and alarms</li>
                <li>Security groups and networking</li>
            </ul>
        </div>

        <div class="info">
            <h2>Next Steps</h2>
            <ol>
                <li>Check RDS connectivity from this instance</li>
                <li>Monitor metrics in CloudWatch Dashboard</li>
                <li>Set up automated deployments with CI/CD</li>
                <li>Add Auto Scaling Group for high availability</li>
            </ol>
        </div>

        <footer style="margin-top: 40px; border-top: 1px solid #ccc; padding-top: 20px;">
            <p><small>DevOps Training - Formation Grenoble</small></p>
        </footer>
    </div>

    <script>
        document.getElementById('hostname').textContent = window.location.hostname;
    </script>
</body>
</html>
EOF

# Create health check endpoint
cat > /var/www/html/health.json << 'EOF'
{
  "status": "healthy",
  "timestamp": "2026-07-20",
  "service": "terraform-devops-lab"
}
EOF

# Log CloudWatch agent installation start
echo "CloudWatch Log Group: ${cloudwatch_group_name}" >> /var/log/messages

# Configure log agent (basic setup)
yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent config
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "${cloudwatch_group_name}",
            "log_stream_name": "{instance_id}-apache-access"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "${cloudwatch_group_name}",
            "log_stream_name": "{instance_id}-apache-error"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${cloudwatch_group_name}",
            "log_stream_name": "{instance_id}-system"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_IDLE",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DISK_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MEM_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json || true

echo "EC2 initialization completed successfully!"
