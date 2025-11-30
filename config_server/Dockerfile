# Generates a Docker image for the config server
# FROM eclipse-temurin:21-jdk-jammy
# COPY target/config_server-0.0.1-SNAPSHOT.jar config_server-0.0.1-SNAPSHOT.jar
# ENTRYPOINT [ "java", "-jar", "config_server-0.0.1-SNAPSHOT.jar" ]


# Stage 1: Build the JAR
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY config_server/ ./config_server/
WORKDIR /app/config_server
RUN ./mvnw clean package -DskipTests

# Stage 2: Run the JAR
FROM eclipse-temurin:21-jdk-jammy
WORKDIR /app
COPY --from=build /app/config_server/target/config_server-0.0.1-SNAPSHOT.jar config_server-0.0.1-SNAPSHOT.jar
ENTRYPOINT ["java", "-jar", "config_server-0.0.1-SNAPSHOT.jar"]




# To build the Docker image, run:
# docker build -t sgaurtech/config_server:v1 .
# To run the Docker container, run:
# docker run -d -p 8071:8071 --name config_server_container sg_tech/config_server:v1
# Make sure to link RabbitMQ container if using Spring Cloud Bus with RabbitMQ
# docker run -d -p 8071:8071 --name config_server_container --
# --link rabbitmq_container:rabbitmq sg_tech/config_server:v1
# To stop and remove the container, run:
# docker stop config_server_container
# docker rm config_server_container
# To push the image to Docker Hub, run:
# docker image push docker.io/sgaurtech/config_server:v1
# To delete the image locally, run:
# docker rmi sgaurtech/config_server:v1