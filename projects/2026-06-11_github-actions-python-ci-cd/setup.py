"""Setup configuration for DevOps Weather CLI."""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="devops-weather-cli",
    version="1.0.0",
    author="Jaouad",
    description="A simple weather CLI tool for DevOps learning",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/jaouadsiouahe1978/claude-devops-tools",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: System :: Monitoring",
    ],
    python_requires=">=3.9",
    entry_points={
        "console_scripts": [
            "weather=src.cli:main",
        ],
    },
)
