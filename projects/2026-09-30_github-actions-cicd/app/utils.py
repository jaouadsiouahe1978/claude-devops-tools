import re
from typing import List


def validate_email(email: str) -> bool:
    """Validate email format."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


def parse_version(version_str: str) -> tuple:
    """Parse semantic version string."""
    parts = version_str.split('.')
    if len(parts) != 3:
        raise ValueError(f"Invalid version format: {version_str}")
    try:
        return tuple(int(p) for p in parts)
    except ValueError as e:
        raise ValueError(f"Version parts must be integers: {e}") from e


def split_camel_case(text: str) -> List[str]:
    """Split camelCase text into words."""
    result = []
    current_word = []
    for char in text:
        if char.isupper() and current_word:
            result.append(''.join(current_word).lower())
            current_word = [char]
        else:
            current_word.append(char)
    if current_word:
        result.append(''.join(current_word).lower())
    return result


def calculate_checksum(data: str) -> str:
    """Calculate simple checksum of data."""
    return hex(sum(ord(c) for c in data) % 256)[2:].upper().zfill(2)
