#!/bin/bash
set -e

NAMESPACE="$1"
APP_NAME="$2"
IMAGE_TAG="$3"

if [ -z "$NAMESPACE" ] || [ -z "$APP_NAME" ] || [ -z "$IMAGE_TAG" ]; then
  echo "Usage: update-manifests.sh <namespace> <app-name> <image-tag>"
  exit 1
fi

DEPLOY_FILE="manifests/${NAMESPACE}/${APP_NAME}/deployment.yaml"

if [ ! -f "$DEPLOY_FILE" ]; then
  echo "Deployment file not found: $DEPLOY_FILE"
  exit 1
fi

AUTO_UPDATE=$(yq '.metadata.annotations."pipeline.autoupdate"' "$DEPLOY_FILE")

if [ "$AUTO_UPDATE" != "true" ]; then
  echo "Autoupdate disabled for $APP_NAME in $NAMESPACE"
  exit 0
fi

IMAGE_REPO=$(yq '.metadata.annotations."pipeline.image-repo"' "$DEPLOY_FILE")

if [ "$IMAGE_REPO" = "null" ] || [ -z "$IMAGE_REPO" ]; then
  IMAGE_REPO=$(yq '.spec.template.spec.containers[0].image' "$DEPLOY_FILE" | cut -d: -f1)
fi

# 🔹 Read current image (BEFORE)
OLD_IMAGE=$(yq '.spec.template.spec.containers[0].image' "$DEPLOY_FILE")
NEW_IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"

echo "----------------------------------------"
echo "Updating deployment manifest"
echo "Namespace : $NAMESPACE"
echo "App       : $APP_NAME"
echo "----------------------------------------"
echo "OLD IMAGE : $OLD_IMAGE"
echo "NEW IMAGE : $NEW_IMAGE"
echo "----------------------------------------"

# 🔹 Apply update
yq -i "
  .spec.template.spec.containers[0].image = \"${NEW_IMAGE}\"
" "$DEPLOY_FILE"

echo "Update completed successfully"

