#!/bin/bash
set -e

ASG_NAME=$1
REGION=${2:-"us-east-1"}

if [ -z "$ASG_NAME" ]; then
  echo "Usage: $0 <asg-name> [region]"
  exit 1
fi

echo "Triggering rolling update on ASG: $ASG_NAME"

# Start instance refresh for rolling update
REFRESH_ID=$(aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "$ASG_NAME" \
  --preferences '{"MinHealthyPercentage": 50, "InstanceWarmup": 120}' \
  --region "$REGION" \
  --query 'InstanceRefreshId' \
  --output text)

echo "Instance refresh started: $REFRESH_ID"

# Wait for refresh to complete
echo "Waiting for rolling update to complete..."
while true; do
  STATUS=$(aws autoscaling describe-instance-refreshes \
    --auto-scaling-group-name "$ASG_NAME" \
    --instance-refresh-ids "$REFRESH_ID" \
    --region "$REGION" \
    --query 'InstanceRefreshes[0].Status' \
    --output text)
  
  echo "Current status: $STATUS"
  
  if [ "$STATUS" = "Successful" ]; then
    echo "Rolling update completed successfully!"
    exit 0
  elif [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ]; then
    echo "Rolling update failed with status: $STATUS"
    exit 1
  fi
  
  sleep 30
done
