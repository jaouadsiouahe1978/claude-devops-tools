"""
DevOps Demo Application
Shows how to work with environment variables and secrets in GitHub Actions
"""

import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    """Configuration class that reads from environment"""

    def __init__(self):
        self.api_key = os.getenv('API_KEY', 'default-key')
        self.environment = os.getenv('ENVIRONMENT', 'development')
        self.debug = os.getenv('DEBUG', 'False').lower() == 'true'
        self.registry = os.getenv('REGISTRY', 'docker.io')

    def __repr__(self):
        return f"Config(env={self.environment}, debug={self.debug})"


def deploy(target_env: str, image: str, api_key: str) -> dict:
    """Simulate deployment with secrets"""
    # Secrets are masked in logs
    masked_key = f"{api_key[:5]}***" if api_key else "***"

    return {
        'status': 'success',
        'environment': target_env,
        'image': image,
        'api_key': masked_key,
        'message': f'Deployed {image} to {target_env}'
    }


def health_check(endpoint: str) -> bool:
    """Check health of deployment"""
    try:
        # This would make a real HTTP request in production
        return True
    except Exception:
        return False


if __name__ == '__main__':
    config = Config()
    print(f"Application Configuration: {config}")

    # Example deployment
    result = deploy(
        target_env=config.environment,
        image='docker.io/app:latest',
        api_key=config.api_key
    )
    print(f"Deployment Result: {result}")
