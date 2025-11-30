#!/bin/bash
# Run this script as: ENV=<env> bash run_app.sh


# Use environment variable for ENV, default to 'default' if not set
ENV=${ENV:-default}

# Deprecated: Restart docker desktop to clear any stale cache issues
# echo "Restarting docker desktop..."
# killall Docker
# killall com.docker.backend
# open -a Docker
# sleep 30


echo "Killing all running processes"
kill -9 $(lsof -ti:8080)
kill -9 $(lsof -ti:8070)
kill -9 $(lsof -ti:8071)

echo "Stopping and removing existing containers..."
docker compose -f docker-compose/$ENV/docker-compose.yml down

# Deprecated: Build JAR files for all services from scratch indidually
# echo "Building JAR files for all services..."
# ./config_server/mvnw -f ./config_server/pom.xml clean package
# ./eureka_server/mvnw -f ./eureka_server/pom.xml clean package
# ./user_profile/mvnw -f ./user_profile/pom.xml clean package


# Remove all build cache
docker builder prune -a -f

# Remove dangling images
docker image prune -f

# Deprecated: Build docker images for all services from scratch individually
# echo "Building new Docker image..."
# docker build -t sgaurtech/config_server:v1 ./config_server
# docker build -t sgaurtech/eureka_server:v1 ./eureka_server
# docker build -t sgaurtech/user_profile:v1 ./user_profile

# Using the docker_build_service.sh script to build images for all services
# Takes the service name and (optionally) the version as arguments.
# If the version is not provided, it extracts it from the service's pom.xml file.
# Builds the Docker image with the correct version.
./docker_build_image_service.sh config_server
./docker_build_image_service.sh eureka_server
./docker_build_image_service.sh user_profile 0.0.1-SNAPSHOT

echo "Starting containers..."
docker compose -f docker-compose/$ENV/docker-compose.yml up -d

# Uncomment below to use Hookdeck for tunneling config server locally
# to be accessible from cloud-hosted services.
# Make sure to have Hookdeck CLI installed and configured.
# More info: https://hookdeck.com/docs/getting-started/installation

# echo "Logging out of Hookdeck..."
# hookdeck logout || true

# echo "Logging in to Hookdeck..."
# hookdeck login

# echo "Starting Hookdeck listener..."
# hookdeck listen 8071 ai-news-platform-config

echo "Done."
