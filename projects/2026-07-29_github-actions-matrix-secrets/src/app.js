/**
 * DevOps Demo Application - Node.js version
 * Shows how to work with environment variables and secrets in GitHub Actions
 */

class Config {
  constructor() {
    this.apiKey = process.env.API_KEY || 'default-key';
    this.environment = process.env.ENVIRONMENT || 'development';
    this.debug = process.env.DEBUG === 'true';
    this.registry = process.env.REGISTRY || 'docker.io';
    this.deployEndpoint = process.env.DEPLOY_ENDPOINT;
  }

  toString() {
    return `Config(env=${this.environment}, debug=${this.debug})`;
  }
}

async function deploy(targetEnv, image, apiKey) {
  const maskedKey = apiKey ? `${apiKey.substring(0, 5)}***` : '***';

  return {
    status: 'success',
    environment: targetEnv,
    image: image,
    apiKey: maskedKey,
    message: `Deployed ${image} to ${targetEnv}`,
    timestamp: new Date().toISOString()
  };
}

async function healthCheck(endpoint) {
  try {
    // This would make a real HTTP request in production
    // const response = await fetch(`${endpoint}/health`);
    // return response.ok;
    return true;
  } catch (error) {
    console.error('Health check failed:', error);
    return false;
  }
}

async function main() {
  const config = new Config();
  console.log(`Application Configuration: ${config}`);

  const result = await deploy(
    config.environment,
    'docker.io/app:latest',
    config.apiKey
  );

  console.log('Deployment Result:', result);

  const health = await healthCheck(config.deployEndpoint);
  console.log(`Health Check: ${health ? '✅ OK' : '❌ FAILED'}`);
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { Config, deploy, healthCheck };
