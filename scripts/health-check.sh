#!/bin/bash
set -e

ALB_DNS=$1
MAX_RETRIES=10
RETRY_INTERVAL=15

if [ -z "$ALB_DNS" ]; then
  echo "Usage: $0 <alb-dns-name>"
  exit 1
fi

echo "Running health check against: http://$ALB_DNS/health"

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i of $MAX_RETRIES..."
  
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    --connect-timeout 10 \
    --max-time 30 \
    "http://$ALB_DNS/health" || echo "000")
  
  if [ "$HTTP_STATUS" = "200" ]; then
    echo "Health check passed! Status: $HTTP_STATUS"
    exit 0
  fi
  
  echo "Health check failed. Status: $HTTP_STATUS. Retrying in ${RETRY_INTERVAL}s..."
  sleep $RETRY_INTERVAL
done

echo "Health check failed after $MAX_RETRIES attempts"
exit 1
