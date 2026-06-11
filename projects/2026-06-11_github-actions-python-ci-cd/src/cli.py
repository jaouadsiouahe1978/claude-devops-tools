#!/usr/bin/env python3
"""
Simple Weather CLI - Demonstrates Python best practices and testing patterns.
"""

import argparse
import sys
import json
from typing import Dict, Optional


class WeatherAPI:
    """Mock weather API client."""

    WEATHER_DATA: Dict[str, Dict[str, str]] = {
        "paris": {"temp": "15°C", "condition": "Cloudy", "humidity": "65%"},
        "london": {"temp": "12°C", "condition": "Rainy", "humidity": "78%"},
        "tokyo": {"temp": "22°C", "condition": "Sunny", "humidity": "55%"},
        "new york": {"temp": "18°C", "condition": "Partly Cloudy", "humidity": "60%"},
    }

    @classmethod
    def get_weather(cls, city: str) -> Optional[Dict[str, str]]:
        """
        Fetch weather data for a city.

        Args:
            city: City name (case-insensitive)

        Returns:
            Weather data dict or None if city not found
        """
        return cls.WEATHER_DATA.get(city.lower())


def format_weather(city: str, data: Dict[str, str]) -> str:
    """Format weather data for display."""
    return (
        f"🌍 Weather in {city.title()}\n"
        f"  Temperature: {data['temp']}\n"
        f"  Condition: {data['condition']}\n"
        f"  Humidity: {data['humidity']}"
    )


def main() -> int:
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Simple weather CLI tool for demonstration"
    )
    parser.add_argument(
        "-c", "--city",
        help="City name to get weather for",
        type=str,
    )
    parser.add_argument(
        "-j", "--json",
        help="Output in JSON format",
        action="store_true",
    )
    parser.add_argument(
        "-l", "--list",
        help="List all available cities",
        action="store_true",
    )
    parser.add_argument(
        "-v", "--version",
        action="version",
        version="%(prog)s 1.0.0",
    )

    args = parser.parse_args()

    if args.list:
        cities = list(WeatherAPI.WEATHER_DATA.keys())
        if args.json:
            print(json.dumps({"available_cities": cities}))
        else:
            print("Available cities:")
            for city in cities:
                print(f"  - {city.title()}")
        return 0

    if not args.city:
        print("Error: --city is required unless using --list", file=sys.stderr)
        return 1

    weather = WeatherAPI.get_weather(args.city)
    if not weather:
        print(
            f"Error: City '{args.city}' not found. Use --list to see available cities.",
            file=sys.stderr,
        )
        return 1

    if args.json:
        print(json.dumps({
            "city": args.city.title(),
            "weather": weather,
        }))
    else:
        print(format_weather(args.city, weather))

    return 0


if __name__ == "__main__":
    sys.exit(main())
