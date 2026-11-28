#!/usr/bin/env bash
# Build the sample app and push it to the ECR repository created by Terraform.
# Usage: ./scripts/push-image.sh <tag>      (example: ./scripts/push-image.sh v1)
set -euo pipefail

TAG="${1:?Usage: $0 <tag>  (for example v1)}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

REPO_URL="$(terraform -chdir="$ROOT" output -raw ecr_repository_url)"
REGISTRY="${REPO_URL%%/*}"
REGION="$(echo "$REGISTRY" | cut -d. -f4)"

echo "Logging in to ${REGISTRY}"
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$REGISTRY"

echo "Building and pushing ${REPO_URL}:${TAG} (linux/amd64)"
docker buildx build \
  --platform linux/amd64 \
  --tag "${REPO_URL}:${TAG}" \
  --push \
  "$ROOT/app"

echo "Done. Set image_tag = \"${TAG}\" in terraform.tfvars and run: terraform apply"
