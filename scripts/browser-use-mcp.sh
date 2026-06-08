#!/usr/bin/env bash
# browser-use MCP server wrapper
# Runs browser-use --mcp using dedicated Python 3.12 venv
# This avoids Python 3.14 incompatibility issues

VENV_PYTHON="C:/Users/PC/.browser-use-env/Scripts/python.exe"

if [ ! -f "$VENV_PYTHON" ]; then
  echo "ERROR: browser-use venv not found at $VENV_PYTHON" >&2
  echo "Run: uv venv C:/Users/PC/.browser-use-env --python 3.12 && uv pip install browser-use --python C:/Users/PC/.browser-use-env/Scripts/python.exe" >&2
  exit 1
fi

exec "$VENV_PYTHON" -m browser_use.skill_cli.main --mcp
