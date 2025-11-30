#!/bin/bash
# Used by run_app.sh to build Docker images for all services
# Usage: ./docker_build_service.sh <service> [version]
# Example: ./docker_build_service.sh config_server 0.0.1-SNAPSHOT

set -e

SERVICE="$1"
VERSION="$2"

if [ -z "$SERVICE" ]; then
  echo "Usage: $0 <service> [version]"
  exit 1
fi

# If version not provided, extract from the service's pom.xml
if [ -z "$VERSION" ]; then
  VERSION=$(xmllint --xpath "string(//project/version)" "$SERVICE/pom.xml")
  if [ -z "$VERSION" ]; then
    echo "Could not determine version from $SERVICE/pom.xml"
    exit 1
  fi
fi

echo "Deleting existing Docker image for $SERVICE..."
docker rmi "sgaurtech/${SERVICE}:v1" || true

echo "Building Docker image for $SERVICE with version $VERSION..."
docker build --build-arg SERVICE="$SERVICE" --build-arg VERSION="$VERSION" -t "sgaurtech/${SERVICE}:v1" .
