#!/bin/bash
set -e # Exit immediately if a command fails

echo "--- Running Automated Test ---"

# 1. Get the public URL of our service
echo "Fetching service URL..."
# This command asks kubectl for the service's DNS name
URL=$(kubectl get svc active-ops-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$URL" ]; then
  echo "❌ ERROR: Could not get service URL."
  exit 1
fi

echo "Service URL: http://$URL"
echo "Waiting for Load Balancer to be ready..."
sleep 10 # Give the ELB a few seconds to warm up

# 2. Call the endpoint and check the message
echo "Curling endpoint..."
MESSAGE=$(curl -s http://$URL | jq -r .message)

# 3. Validate the response
if [ "$MESSAGE" == "Automate all the things!" ]; then
  echo "✅ Test Passed! Received correct message."
  exit 0
else
  echo "❌ Test Failed! Received: '$MESSAGE'"
  exit 1
fi