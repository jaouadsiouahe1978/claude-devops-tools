import json
import logging
from typing import Dict, Any

from app.utils import validate_email, parse_version

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Application:
    """Main application class."""

    def __init__(self, config: Dict[str, Any] = None):
        """Initialize the application."""
        self.config = config or {}
        self.version = self.config.get('version', '0.1.0')
        logger.info(f"Application initialized with version {self.version}")

    def validate_config(self) -> bool:
        """Validate application configuration."""
        required_fields = ['version', 'name']
        for field in required_fields:
            if field not in self.config:
                logger.error(f"Missing required field: {field}")
                return False

        try:
            parse_version(self.config['version'])
        except ValueError as e:
            logger.error(f"Invalid version format: {e}")
            return False

        return True

    def get_status(self) -> Dict[str, Any]:
        """Get application status."""
        return {
            'status': 'running',
            'version': self.version,
            'config': self.config
        }

    def process_user(self, email: str, name: str) -> Dict[str, Any]:
        """Process user data."""
        if not validate_email(email):
            logger.warning(f"Invalid email: {email}")
            return {'success': False, 'error': 'Invalid email format'}

        logger.info(f"Processing user: {name} ({email})")
        return {
            'success': True,
            'email': email,
            'name': name
        }


def main():
    """Main entry point."""
    config = {
        'version': '0.1.0',
        'name': 'github-actions-cicd',
        'environment': 'development'
    }

    app = Application(config)

    if app.validate_config():
        logger.info("Configuration is valid")
        status = app.get_status()
        print(json.dumps(status, indent=2))
    else:
        logger.error("Configuration validation failed")
        return 1

    return 0


if __name__ == '__main__':
    exit(main())
