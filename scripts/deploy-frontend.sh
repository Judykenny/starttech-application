#!/bin/bash
set -e

S3_BUCKET=$1
CLOUDFRONT_ID=$2
BUILD_DIR=${3:-"frontend/build"}

if [ -z "$S3_BUCKET" ] || [ -z "$CLOUDFRONT_ID" ]; then
  echo "Usage: $0 <s3-bucket> <cloudfront-distribution-id> [build-dir]"
  exit 1
fi

echo "Deploying frontend to S3 bucket: $S3_BUCKET"

# Sync build files to S3
aws s3 sync "$BUILD_DIR" "s3://$S3_BUCKET" \
  --delete \
  --cache-control "public, max-age=31536000" \
  --exclude "index.html"

# Upload index.html with no-cache so updates are immediate
aws s3 cp "$BUILD_DIR/index.html" "s3://$S3_BUCKET/index.html" \
  --cache-control "no-cache, no-store, must-revalidate"

echo "Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$CLOUDFRONT_ID" \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text)

echo "CloudFront invalidation created: $INVALIDATION_ID"
echo "Frontend deployment complete!"
