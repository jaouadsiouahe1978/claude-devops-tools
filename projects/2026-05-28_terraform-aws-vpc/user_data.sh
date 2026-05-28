#!/bin/bash
set -e

# Log everything to /var/log/user-data.log
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting User Data Script"
echo "=========================================="
echo "Timestamp: $(date)"

# Update system
echo "[1/5] Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Nginx
echo "[2/5] Installing Nginx..."
apt-get install -y nginx

# Create custom index.html
echo "[3/5] Creating custom Nginx homepage..."
cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Training - Terraform AWS VPC</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            border-radius: 10px;
            padding: 40px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            max-width: 600px;
        }
        h1 {
            color: #333;
            margin-top: 0;
        }
        .success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .info {
            background: #d1ecf1;
            border: 1px solid #bee5eb;
            color: #0c5460;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        code {
            background: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: monospace;
        }
        .timestamp {
            color: #999;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Terraform AWS VPC - Successfully Deployed!</h1>

        <div class="success">
            <strong>✓ Success!</strong> Your Nginx instance is running on this EC2 instance deployed via Terraform!
        </div>

        <div class="info">
            <h3>Project Information:</h3>
            <p><strong>Project:</strong> DevOps Training - Terraform AWS VPC</p>
            <p><strong>Date:</strong> 2026-05-28</p>
            <p><strong>Technology Stack:</strong> Terraform, AWS, EC2, VPC, Nginx</p>
            <p><strong>Instance Type:</strong> t2.micro</p>
        </div>

        <h3>What You've Learned:</h3>
        <ul>
            <li>Creating VPCs with Subnets in AWS</li>
            <li>Managing Security Groups with Terraform</li>
            <li>Provisioning EC2 instances with user_data scripts</li>
            <li>Using Terraform state management</li>
            <li>Infrastructure as Code best practices</li>
        </ul>

        <h3>Next Steps:</h3>
        <ol>
            <li>Check your Terraform outputs: <code>terraform output</code></li>
            <li>Explore your AWS Console to see created resources</li>
            <li>Scale your infrastructure by modifying variables</li>
            <li>Implement S3 backend for state management</li>
            <li>Add more resources: RDS, ALB, Auto Scaling</li>
        </ol>

        <div class="timestamp">
            Page generated at: <strong id="timestamp"></strong>
        </div>
    </div>

    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Start Nginx
echo "[4/5] Starting Nginx service..."
systemctl start nginx
systemctl enable nginx

# Install CloudWatch agent (optional, based on variable)
echo "[5/5] Installation complete!"
echo "=========================================="
echo "User Data Script finished at $(date)"
echo "=========================================="
