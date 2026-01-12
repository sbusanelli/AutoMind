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

echo "[TEST] Node.js service health check"

# Start the Node.js service in the background
node index.js &
SERVER_PID=$!

# Wait for the server to start
sleep 2

# Perform the health check
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health)
RESPONSE_BODY=$(curl -s http://localhost:3000/health)

# Stop the server
kill $SERVER_PID

# Check the results
if [ "$HTTP_STATUS" -eq 200 ] && [ "$RESPONSE_BODY" == '{"status":"ok"}' ]; then
  echo "  [PASS] Health check successful."
else
  echo "  [FAIL] Health check failed."
  echo "    HTTP Status: $HTTP_STATUS"
  echo "    Response Body: $RESPONSE_BODY"
  exit 1
fi

# --- End Test Cases ---

echo "All tests passed!"
exit 0
