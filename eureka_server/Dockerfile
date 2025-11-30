# Generates a Docker image for the config server
FROM eclipse-temurin:21-jdk-jammy
COPY target/eureka_server-0.0.1-SNAPSHOT.jar eureka_server-0.0.1-SNAPSHOT.jar
ENTRYPOINT [ "java", "-jar", "eureka_server-0.0.1-SNAPSHOT.jar" ]

# To build the Docker image, run:
# docker build -t sgaurtech/eureka_server:v1 .
# To run the Docker container, run:
# docker run -d -p 8071:8071 --name eureka_server_container sgaurtech/eureka_server:v1
# Make sure to link RabbitMQ container if using Spring Cloud Bus with RabbitMQ
# docker run -d -p 8071:8071 --name eureka_server_container --
# --link rabbitmq_container:rabbitmq sgaurtech/eureka_server:v1
# To stop and remove the container, run:
# docker stop eureka_server_container
# docker rm eureka_server_container
# To push the image to Docker Hub, run:
# docker image push docker.io/sgaurtech/eureka_server:v1
# To delete the image locally, run:
# docker rmi sgaurtech/eureka_server:v1