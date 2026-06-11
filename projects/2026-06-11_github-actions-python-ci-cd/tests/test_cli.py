"""Unit tests for weather CLI module."""

import pytest
from io import StringIO
import sys
from src.cli import WeatherAPI, format_weather, main


class TestWeatherAPI:
    """Tests for WeatherAPI class."""

    def test_get_weather_valid_city(self):
        """Test fetching weather for a valid city."""
        weather = WeatherAPI.get_weather("paris")
        assert weather is not None
        assert weather["temp"] == "15°C"
        assert weather["condition"] == "Cloudy"
        assert weather["humidity"] == "65%"

    def test_get_weather_case_insensitive(self):
        """Test that city lookup is case-insensitive."""
        weather_lower = WeatherAPI.get_weather("paris")
        weather_upper = WeatherAPI.get_weather("PARIS")
        weather_mixed = WeatherAPI.get_weather("PaRiS")
        assert weather_lower == weather_upper == weather_mixed

    def test_get_weather_invalid_city(self):
        """Test fetching weather for non-existent city."""
        weather = WeatherAPI.get_weather("atlantis")
        assert weather is None

    def test_available_cities(self):
        """Test that known cities have data."""
        cities = ["paris", "london", "tokyo", "new york"]
        for city in cities:
            weather = WeatherAPI.get_weather(city)
            assert weather is not None, f"Weather data missing for {city}"
            assert "temp" in weather
            assert "condition" in weather
            assert "humidity" in weather


class TestFormatWeather:
    """Tests for weather formatting function."""

    def test_format_weather_output(self):
        """Test weather formatting."""
        weather = {"temp": "15°C", "condition": "Sunny", "humidity": "50%"}
        result = format_weather("Paris", weather)
        assert "Paris" in result
        assert "15°C" in result
        assert "Sunny" in result
        assert "50%" in result

    def test_format_weather_contains_emoji(self):
        """Test that formatted output contains emoji."""
        weather = {"temp": "15°C", "condition": "Sunny", "humidity": "50%"}
        result = format_weather("Paris", weather)
        assert "🌍" in result


class TestMainCLI:
    """Integration tests for main CLI function."""

    def test_main_without_arguments(self, capsys):
        """Test that missing --city argument shows error."""
        sys.argv = ["weather"]
        result = main()
        assert result == 1
        captured = capsys.readouterr()
        assert "Error" in captured.err or "required" in captured.err.lower()

    def test_main_list_cities(self, capsys):
        """Test listing available cities."""
        sys.argv = ["weather", "--list"]
        result = main()
        assert result == 0
        captured = capsys.readouterr()
        assert "paris" in captured.out.lower()
        assert "london" in captured.out.lower()

    def test_main_list_cities_json(self, capsys):
        """Test listing cities in JSON format."""
        sys.argv = ["weather", "--list", "--json"]
        result = main()
        assert result == 0
        captured = capsys.readouterr()
        assert "available_cities" in captured.out
        assert "paris" in captured.out.lower()

    def test_main_get_weather(self, capsys):
        """Test getting weather for a city."""
        sys.argv = ["weather", "--city", "paris"]
        result = main()
        assert result == 0
        captured = capsys.readouterr()
        assert "Paris" in captured.out
        assert "15°C" in captured.out

    def test_main_get_weather_json(self, capsys):
        """Test getting weather in JSON format."""
        sys.argv = ["weather", "--city", "paris", "--json"]
        result = main()
        assert result == 0
        captured = capsys.readouterr()
        assert "weather" in captured.out
        assert "paris" in captured.out.lower()

    def test_main_invalid_city(self, capsys):
        """Test error handling for invalid city."""
        sys.argv = ["weather", "--city", "atlantis"]
        result = main()
        assert result == 1
        captured = capsys.readouterr()
        assert "not found" in captured.err.lower()

    def test_main_version(self, capsys):
        """Test version flag."""
        sys.argv = ["weather", "--version"]
        with pytest.raises(SystemExit) as exc_info:
            main()
        assert exc_info.value.code == 0


class TestEdgeCases:
    """Tests for edge cases and error handling."""

    def test_empty_weather_data(self):
        """Test handling of empty input."""
        result = WeatherAPI.get_weather("")
        assert result is None

    def test_whitespace_in_city_name(self):
        """Test city names with whitespace."""
        weather = WeatherAPI.get_weather("new york")
        assert weather is not None
        assert weather["temp"] == "18°C"

    def test_special_characters_in_city(self):
        """Test that special characters don't break lookup."""
        weather = WeatherAPI.get_weather("paris!")
        assert weather is None
