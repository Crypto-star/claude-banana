#!/bin/bash
# Check if Gemini Image Generator is properly configured
set -euo pipefail

WARNINGS=""

# Check for API key
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  STATE_FILE=".claude/gemini-image-gen.local.md"
  if [[ ! -f "$STATE_FILE" ]]; then
    WARNINGS="Gemini Image Generator: No API key configured. Set GEMINI_API_KEY env var or create .claude/gemini-image-gen.local.md with your key."
  else
    # Extract api_key from YAML frontmatter using awk (cross-platform)
    API_KEY=$(awk '/^---$/{n++; next} n==1 && /^api_key:/{gsub(/^api_key:[[:space:]]*/, ""); gsub(/^["'"'"']|["'"'"']$/, ""); print; exit}' "$STATE_FILE")
    if [[ -z "$API_KEY" || "$API_KEY" == "your-gemini-api-key-here" ]]; then
      WARNINGS="Gemini Image Generator: API key in .claude/gemini-image-gen.local.md appears to be a placeholder. Please set your actual Gemini API key."
    fi
  fi
fi

# Check for curl
if ! command -v curl &>/dev/null; then
  if [[ -n "$WARNINGS" ]]; then
    WARNINGS="$WARNINGS\n"
  fi
  WARNINGS="${WARNINGS}Gemini Image Generator: curl not found. Please install curl."
fi

if [[ -n "$WARNINGS" ]]; then
  echo "$WARNINGS"
fi

exit 0
