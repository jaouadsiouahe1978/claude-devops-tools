#!/bin/bash
set -e

# Update system
yum update -y

# Install Docker
amazon-linux-extras install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Create simple Node.js API in Docker
docker run -d \
  --name demo-api \
  --restart always \
  -p 8080:8080 \
  node:18-alpine \
  node -e '
    const http = require("http");
    const server = http.createServer((req, res) => {
      if (req.url === "/health") {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ status: "healthy" }));
      } else if (req.url === "/api/hello") {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({
          message: "Hello from AWS Auto-Scaling!",
          hostname: require("os").hostname(),
          timestamp: new Date().toISOString()
        }));
      } else {
        res.writeHead(404);
        res.end("Not found");
      }
    });
    server.listen(8080, () => console.log("Server running on port 8080"));
  '

# Log completion
echo "User data script completed at $(date)" > /var/log/user-data.log
