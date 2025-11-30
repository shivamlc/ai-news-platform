# Generates a Docker image for the user_profile service
FROM eclipse-temurin:21-jdk-jammy
COPY target/user_profile-0.0.1-SNAPSHOT.jar user_profile-0.0.1-SNAPSHOT.jar
ENTRYPOINT [ "java", "-jar", "user_profile-0.0.1-SNAPSHOT.jar" ]

# To build the Docker image, run:
# docker build -t sgaurtech/user_profile:v1 .
# To run the Docker container, run:
# docker run -d -p 8071:8071 --name user_profile_container sg_tech/user_profile:v1
# Make sure to link RabbitMQ container if using Spring Cloud Bus with RabbitMQ
# docker run -d -p 8071:8071 --name user_profile_container --
# --link rabbitmq_container:rabbitmq sg_tech/user_profile:v1
# To stop and remove the container, run:
# docker stop user_profile_container
# docker rm user_profile_container
# To push the image to Docker Hub, run:
# docker image push docker.io/sgaurtech/user_profile:v1
# To delete the image locally, run:
# docker rmi sgaurtech/user_profile:v1