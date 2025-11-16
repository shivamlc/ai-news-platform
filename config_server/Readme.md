# Build all modules
- from dir `ai-news-platform`, run `mvn clean install -U`

# Run application locally in vs code

- cd `config_server/src/main/java/com/sg_tech/config_server`
- run `mvn spring-boot:run`

# Common actuator endpoints

With your current configuration (management.endpoints.web.exposure.include: "*") in application.yaml, all Spring Boot Actuator endpoints will be exposed.

Common actuator endpoints include:

/actuator/health — Application health status
/actuator/info — Application info
/actuator/env — Environment properties
/actuator/metrics — Application metrics
/actuator/loggers — Logger levels
/actuator/configprops — Configuration properties
/actuator/beans — Beans in the application context
/actuator/mappings — Request mappings
/actuator/threaddump — Thread dump
/actuator/httptrace — HTTP trace
/actuator/scheduledtasks — Scheduled tasks
/actuator/conditions — Auto-configuration conditions
/actuator/refresh — Refresh configuration (if enabled)
/actuator/prometheus — Prometheus metrics (if enabled)

You can see the full list by visiting /actuator in your running application.