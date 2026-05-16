#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code on the web environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "==> Installing DevOps linting tools..."

# Install yamllint for YAML validation
if ! command -v yamllint &>/dev/null; then
  pip3 install --quiet yamllint
  echo "  ✓ yamllint installed"
else
  echo "  ✓ yamllint already available"
fi

# Install shellcheck for shell script linting
if ! command -v shellcheck &>/dev/null; then
  apt-get install -y -qq shellcheck 2>/dev/null || pip3 install --quiet shellcheck-py
  echo "  ✓ shellcheck installed"
else
  echo "  ✓ shellcheck already available"
fi

echo "==> DevOps tools ready."
