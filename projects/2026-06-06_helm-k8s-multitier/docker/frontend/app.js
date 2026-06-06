const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(`
    <html>
      <head>
        <title>Frontend - Helm K8s Multi-Tier App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 50px; background: #f0f0f0; }
          .container { background: white; padding: 30px; border-radius: 8px; }
          h1 { color: #333; }
          .status { padding: 10px; background: #d4edda; border-radius: 4px; margin: 10px 0; }
          .endpoint { color: #0066cc; font-family: monospace; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🚀 Frontend - Helm Kubernetes Multi-Tier App</h1>
          <div class="status">
            <p><strong>Status:</strong> ✅ Running on Kubernetes</p>
            <p><strong>Pod:</strong> ${process.env.HOSTNAME}</p>
            <p><strong>Environment:</strong> ${process.env.ENVIRONMENT || 'development'}</p>
          </div>
          <h2>Backend API Health</h2>
          <p>API Endpoint: <span class="endpoint">http://${process.env.BACKEND_SERVICE || 'backend'}:8000/health</span></p>
          <p>Database Status: Check logs for details</p>
        </div>
      </body>
    </html>
  `);
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Frontend server running on port ${PORT}`);
  console.log(`Pod: ${process.env.HOSTNAME}`);
  console.log(`Environment: ${process.env.ENVIRONMENT || 'development'}`);
});
