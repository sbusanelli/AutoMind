#!/bin/bash

# A simple test runner

echo "Running tests..."

# --- Test Cases ---

echo "[TEST] Check for README.md"
if [ -f "README.md" ]; then
  echo "  [PASS] README.md found."
else
  echo "  [FAIL] README.md not found."
  exit 1
fi

# --- End Test Cases ---

echo "All tests passed!"
exit 0
