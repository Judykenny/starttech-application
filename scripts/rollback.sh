#!/bin/bash
set -e

ASG_NAME=$1
REGION=${2:-"us-east-1"}

if [ -z "$ASG_NAME" ]; then
  echo "Usage: $0 <asg-name> [region]"
  exit 1
fi

echo "Rolling back ASG: $ASG_NAME"

# Cancel any in-progress instance refresh
aws autoscaling cancel-instance-refresh \
  --auto-scaling-group-name "$ASG_NAME" \
  --region "$REGION" 2>/dev/null || echo "No active refresh to cancel"

# Get the previous launch template version
CURRENT_VERSION=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --region "$REGION" \
  --query 'AutoScalingGroups[0].LaunchTemplate.Version' \
  --output text)

echo "Current launch template version: $CURRENT_VERSION"

if [ "$CURRENT_VERSION" -gt 1 ]; then
  PREVIOUS_VERSION=$((CURRENT_VERSION - 1))
  echo "Rolling back to version: $PREVIOUS_VERSION"
  
  LAUNCH_TEMPLATE_ID=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --region "$REGION" \
    --query 'AutoScalingGroups[0].LaunchTemplate.LaunchTemplateId' \
    --output text)

  aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "$ASG_NAME" \
    --launch-template "LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version=$PREVIOUS_VERSION" \
    --region "$REGION"

  aws autoscaling start-instance-refresh \
    --auto-scaling-group-name "$ASG_NAME" \
    --preferences '{"MinHealthyPercentage": 50, "InstanceWarmup": 120}' \
    --region "$REGION"

  echo "Rollback initiated successfully"
else
  echo "Already at version 1, cannot rollback further"
  exit 1
fi
