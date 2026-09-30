import pytest
from app.utils import (
    validate_email,
    parse_version,
    split_camel_case,
    calculate_checksum
)


class TestValidateEmail:
    """Test email validation."""

    def test_valid_email(self):
        """Test valid email addresses."""
        assert validate_email("user@example.com") is True
        assert validate_email("john.doe@company.co.uk") is True
        assert validate_email("test+tag@domain.org") is True

    def test_invalid_email(self):
        """Test invalid email addresses."""
        assert validate_email("invalid.email") is False
        assert validate_email("@example.com") is False
        assert validate_email("user@") is False
        assert validate_email("") is False


class TestParseVersion:
    """Test version parsing."""

    def test_valid_version(self):
        """Test valid semantic versions."""
        assert parse_version("1.2.3") == (1, 2, 3)
        assert parse_version("0.1.0") == (0, 1, 0)
        assert parse_version("10.20.30") == (10, 20, 30)

    def test_invalid_version(self):
        """Test invalid versions."""
        with pytest.raises(ValueError):
            parse_version("1.2")
        with pytest.raises(ValueError):
            parse_version("1.2.a")
        with pytest.raises(ValueError):
            parse_version("1.2.3.4")


class TestSplitCamelCase:
    """Test camelCase splitting."""

    def test_simple_camel_case(self):
        """Test simple camelCase strings."""
        assert split_camel_case("helloWorld") == ["hello", "world"]
        assert split_camel_case("myVariableName") == ["my", "variable", "name"]

    def test_single_word(self):
        """Test single words."""
        assert split_camel_case("hello") == ["hello"]

    def test_pascal_case(self):
        """Test PascalCase strings."""
        assert split_camel_case("HelloWorld") == ["hello", "world"]


class TestCalculateChecksum:
    """Test checksum calculation."""

    def test_checksum(self):
        """Test checksum calculation."""
        result = calculate_checksum("test")
        assert isinstance(result, str)
        assert len(result) == 2

    def test_checksum_consistency(self):
        """Test checksum consistency."""
        data = "github-actions"
        checksum1 = calculate_checksum(data)
        checksum2 = calculate_checksum(data)
        assert checksum1 == checksum2
