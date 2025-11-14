#!/bin/bash

# Fix TUSKit bug in TUSFileData.m
# Replaces url.filePathURL with url.path on line 23

set -e

TUSKIT_FILE="${PODS_ROOT}/TUSKit/TUSKit/TUSFileData.m"

if [ ! -f "$TUSKIT_FILE" ]; then
  echo "Warning: TUSFileData.m not found at $TUSKIT_FILE"
  exit 0
fi

# Check if fix is already applied (if url.filePathURL doesn't exist, fix is applied)
if ! grep -q "url\.filePathURL" "$TUSKIT_FILE"; then
  echo "TUSKit fix already applied"
  exit 0
fi

# Apply the fix: replace url.filePathURL with url.path
sed -i '' 's/url\.filePathURL/url.path/g' "$TUSKIT_FILE"

echo "TUSKit bug fixed: replaced url.filePathURL with url.path in TUSFileData.m"

