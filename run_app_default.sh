#!/bin/bash
# Remove local config server image

docker rmi sgaurtech/config_server:v1 || true

echo "Building new Docker image..."
docker build -t sgaurtech/config_server:v1 ./config_server

echo "Stopping and removing existing containers..."
docker compose -f docker-compose/default/docker-compose.yml down

echo "Starting containers..."
docker compose -f docker-compose/default/docker-compose.yml up -d

echo "Done."
