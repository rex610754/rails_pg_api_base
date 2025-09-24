#!/bin/bash
set -euo pipefail

# Usage:
# ./build_prod_image.sh <image_name> [platform] [--no-cache]

# Example:
# In my case, I used ec2 instance which had linux/amd64 architecture and my local machine is arm64
# ./build_prod_image.sh <docker_account>/<image_name>:latest linux/amd64 --no-cache

# --- Argument validation ---
if [ $# -lt 1 ]; then
  echo "Usage: $0 <image_name> [platform] [--no-cache]"
  exit 1
fi

IMAGE_NAME=$1
PLATFORM=${2:-}
NOCACHE=${3:-}

# --- Git sanity check ---
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a git repository"
  exit 1
fi

echo "===> Resetting git repo..."
git reset --hard
git clean -fd
git checkout main
git pull origin main

# --- Docker login check ---
if ! docker info 2>/dev/null | grep -q 'Username:'; then
  echo "Error: not logged in to Docker registry (docker login)"
  exit 1
fi

# --- Build image ---
echo "===> Building Docker image..."
BUILD_OPTS=()
[ "$NOCACHE" = "--no-cache" ] && BUILD_OPTS+=(--no-cache)

if [ -n "$PLATFORM" ]; then
  if ! docker buildx version >/dev/null 2>&1; then
    echo "Error: docker buildx not available, cannot build with platform"
    exit 1
  fi
  docker buildx build --platform "$PLATFORM" -t "$IMAGE_NAME" "${BUILD_OPTS[@]}" .
else
  docker build -t "$IMAGE_NAME" "${BUILD_OPTS[@]}" .
fi

# --- Push image ---
echo "===> Pushing Docker image..."
docker push "$IMAGE_NAME"

echo "✅ Build and push completed successfully!"
