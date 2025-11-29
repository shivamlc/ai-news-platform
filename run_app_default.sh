#!/bin/bash
# Remove local config server image

echo "Killing all running processes"
kill -9 $(lsof -ti:8080)
kill -9 $(lsof -ti:8070)
kill -9 $(lsof -ti:8071)

echo "Stopping and removing existing containers..."
docker compose -f docker-compose/default/docker-compose.yml down

docker rmi sgaurtech/config_server:v1 || true
docker rmi sgaurtech/user_profile:v1 || true

echo "Building new Docker image..."
docker build -t sgaurtech/config_server:v1 ./config_server
docker build -t sgaurtech/user_profile:v1 ./user_profile

echo "Starting containers..."
docker compose -f docker-compose/default/docker-compose.yml up -d

# echo "Logging out of Hookdeck..."
# hookdeck logout || true

# echo "Logging in to Hookdeck..."
# hookdeck login

# echo "Starting Hookdeck listener..."
# hookdeck listen 8071 ai-news-platform-config

echo "Done."
