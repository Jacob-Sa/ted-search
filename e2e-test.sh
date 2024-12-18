#!/bin/bash

# Configuration
SERVER_URL="http://localhost:8080"  # Replace with your server's URL if different
EXPECTED_STATUS=200                 # Expected HTTP status code

# Perform the test
echo "Running E2E test for $SERVER_URL..."

response=$(curl -o /dev/null -s -w "%{http_code}\n" $SERVER_URL)

if [[ $response -eq $EXPECTED_STATUS ]]; then
  echo "SUCCESS: Server is up and returned HTTP $response."
  exit 0
else
  echo "FAILURE: Server returned HTTP $response instead of $EXPECTED_STATUS."
  exit 1
fi
