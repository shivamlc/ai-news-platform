# Generates a Docker image for a specified service
ARG SERVICE
ARG VERSION=0.0.1-SNAPSHOT
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml . 
COPY $SERVICE/ ./$SERVICE/
WORKDIR /app/$SERVICE
RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:21-jdk-jammy
WORKDIR /app
COPY --from=build /app/$SERVICE/target/${SERVICE}-${VERSION}.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
