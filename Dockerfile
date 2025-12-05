# Generates a Docker image for a specified service
ARG SERVICE
ARG VERSION=0.0.1-SNAPSHOT

# Build stage
FROM maven:3.9.6-eclipse-temurin-21 AS build
# ARGs need to be redeclared in each stage where they're used.
ARG SERVICE
ARG VERSION
WORKDIR /app

# Copy parent pom if exists (for multi-module projects)
COPY pom.xml* ./

# Copy service-specific files
COPY ${SERVICE}/pom.xml ${SERVICE}/
COPY ${SERVICE}/src ${SERVICE}/src

# Build the service
WORKDIR /app/${SERVICE}
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-jammy
ARG SERVICE
ARG VERSION
WORKDIR /app

# Copy the built jar
COPY --from=build /app/${SERVICE}/target/${SERVICE}-${VERSION}.jar app.jar

# Create non-root user for security
# Running as non-root is a security best practice.
RUN groupadd -r spring && useradd -r -g spring spring
RUN chown -R spring:spring /app
USER spring:spring

# Use exec form for proper signal handling
ENTRYPOINT ["java", "-jar", "app.jar"]