#!/usr/bin/env bash
set -uo pipefail

STATUS=$1
EXIT_CODE=$2
TARGET=$3
OUTPUT=$4

jq -n \
  --arg status "$STATUS" \
  --argjson exit_code "$EXIT_CODE" \
  --arg target "$TARGET" \
  --arg output "$OUTPUT" \
  '{
    status: $status,
    exit_code: $exit_code,
    target: $target,
    output: $output
  }'
