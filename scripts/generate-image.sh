#!/bin/bash
# Generate images using the Gemini REST API
# Zero dependencies beyond curl and base64 (available on all OS)
set -euo pipefail

usage() {
  echo "Usage: $0 -p <prompt> -o <output_file> [-m <model>] [-k <api_key>]"
  echo ""
  echo "Options:"
  echo "  -p  Image generation prompt (required)"
  echo "  -o  Output file path (required, e.g. output.png)"
  echo "  -m  Model name (default: gemini-2.5-flash-image)"
  echo "  -k  Gemini API key (or set GEMINI_API_KEY env var)"
  exit 1
}

PROMPT=""
OUTPUT=""
MODEL=""
API_KEY=""

while getopts "p:o:m:k:" opt; do
  case $opt in
    p) PROMPT="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    m) MODEL="$OPTARG" ;;
    k) API_KEY="$OPTARG" ;;
    *) usage ;;
  esac
done

if [[ -z "$PROMPT" || -z "$OUTPUT" ]]; then
  usage
fi

# --- Resolve API key ---
# Priority: -k flag > GEMINI_API_KEY env > settings file
if [[ -z "$API_KEY" ]]; then
  API_KEY="${GEMINI_API_KEY:-}"
fi

if [[ -z "$API_KEY" ]]; then
  SETTINGS_FILE=".claude/gemini-image-gen.local.md"
  if [[ -f "$SETTINGS_FILE" ]]; then
    # Extract api_key from YAML frontmatter (between --- markers)
    API_KEY=$(awk '/^---$/{n++; next} n==1 && /^api_key:/{gsub(/^api_key:[[:space:]]*/, ""); gsub(/^["'"'"']|["'"'"']$/, ""); print; exit}' "$SETTINGS_FILE")
  fi
fi

if [[ -z "$API_KEY" ]]; then
  echo '{"error": "No Gemini API key found. Set GEMINI_API_KEY environment variable or configure in .claude/gemini-image-gen.local.md"}' >&2
  exit 1
fi

# --- Resolve model ---
if [[ -z "$MODEL" ]]; then
  SETTINGS_FILE=".claude/gemini-image-gen.local.md"
  if [[ -f "$SETTINGS_FILE" ]]; then
    FILE_MODEL=$(awk '/^---$/{n++; next} n==1 && /^model:/{gsub(/^model:[[:space:]]*/, ""); gsub(/^["'"'"']|["'"'"']$/, ""); print; exit}' "$SETTINGS_FILE")
    if [[ -n "$FILE_MODEL" ]]; then
      MODEL="$FILE_MODEL"
    fi
  fi
fi
MODEL="${MODEL:-gemini-2.5-flash-image}"

# --- Detect base64 decode command (cross-platform) ---
BASE64_DECODE=""
if echo "dGVzdA==" | base64 --decode &>/dev/null; then
  BASE64_DECODE="base64 --decode"
elif echo "dGVzdA==" | base64 -d &>/dev/null; then
  BASE64_DECODE="base64 -d"
elif echo "dGVzdA==" | base64 -D &>/dev/null; then
  BASE64_DECODE="base64 -D"
else
  echo '{"error": "No base64 decode command found on this system"}' >&2
  exit 1
fi

# --- Build request body ---
# Escape the prompt for JSON (handle quotes, backslashes, newlines)
ESCAPED_PROMPT=$(printf '%s' "$PROMPT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')

REQUEST_BODY=$(cat <<EOF
{
  "contents": [{"parts": [{"text": "$ESCAPED_PROMPT"}]}],
  "generationConfig": {"responseModalities": ["image", "text"]}
}
EOF
)

# --- Call Gemini API ---
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent"

HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "$API_URL" \
  -H "x-goog-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_BODY" 2>&1) || {
  echo "{\"error\": \"curl request failed: $(echo "$HTTP_RESPONSE" | tail -1)\"}" >&2
  exit 1
}

HTTP_CODE=$(echo "$HTTP_RESPONSE" | tail -1)
RESPONSE_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" != "200" ]]; then
  # Try to extract error message from response
  ERROR_MSG=$(echo "$RESPONSE_BODY" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"message"[[:space:]]*:[[:space:]]*"//; s/"$//' || echo "HTTP $HTTP_CODE")
  echo "{\"error\": \"Gemini API error ($HTTP_CODE): $ERROR_MSG\"}" >&2
  exit 1
fi

# --- Extract base64 image data from response ---
# The response JSON has: candidates[0].content.parts[].inlineData.data
# Using grep to extract the base64 data field

# Check if response contains image data (inlineData or inline_data)
if ! echo "$RESPONSE_BODY" | grep -q '"data"'; then
  # No image data - might be text-only response
  TEXT=$(echo "$RESPONSE_BODY" | grep -o '"text"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"text"[[:space:]]*:[[:space:]]*"//; s/"$//')
  echo "{\"error\": \"No image in response. Model returned text only.\", \"text_response\": \"$TEXT\"}" >&2
  exit 1
fi

# Extract the base64 data - it's the largest "data" field value
# Use awk to find the data field and extract its value
IMAGE_DATA=$(echo "$RESPONSE_BODY" | grep -o '"data"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"data"[[:space:]]*:[[:space:]]*"//; s/"$//')

if [[ -z "$IMAGE_DATA" ]]; then
  echo '{"error": "Failed to extract image data from API response"}' >&2
  exit 1
fi

# --- Decode and save image ---
# Create parent directory if needed
OUTPUT_DIR=$(dirname "$OUTPUT")
if [[ "$OUTPUT_DIR" != "." && ! -d "$OUTPUT_DIR" ]]; then
  mkdir -p "$OUTPUT_DIR"
fi

echo "$IMAGE_DATA" | $BASE64_DECODE > "$OUTPUT" 2>/dev/null

if [[ ! -s "$OUTPUT" ]]; then
  rm -f "$OUTPUT"
  echo '{"error": "Failed to decode image data. Output file is empty."}' >&2
  exit 1
fi

# --- Output result ---
FILE_SIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo "{\"success\": true, \"output_path\": \"$OUTPUT\", \"model\": \"$MODEL\", \"file_size\": $FILE_SIZE}"
