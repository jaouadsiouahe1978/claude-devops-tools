const Calculator = require('./calculator');

console.log('🚀 DevOps Application Started');

const calc = new Calculator();

// Example calculations
console.log(`2 + 3 = ${calc.add(2, 3)}`);
console.log(`10 - 4 = ${calc.subtract(10, 4)}`);
console.log(`5 * 6 = ${calc.multiply(5, 6)}`);
console.log(`20 / 4 = ${calc.divide(20, 4)}`);

// Simple HTTP server for health checks
const http = require('http');

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy', timestamp: new Date() }));
  } else if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('<h1>DevOps App Running</h1><p>CI/CD Pipeline in Action!</p>');
  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`📡 Server listening on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
