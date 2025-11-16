# Build all modules
- from dir `ai-news-platform`, run:
 ```bash
  mvn clean install -U
  ```

# Run application locally in vs code

```bash
cd config_server/src/main/java/com/sg_tech/config_server
```
```bash
mvn spring-boot:run
```

# Export vars from .env and run application 
```bash
cd config_server/src/main/java/com/sg_tech/config_server
```
```bash
export $(grep -v '^#' ../.env | xargs) && mvn spring-boot:run
```

# Utility commands
- kill the process running on port 8071:
```bash
kill -9 $(lsof -ti:8071)
```

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

# Endpoints for checking client service configs in various profiles (eg: user_profile service)

- `http://localhost:8071/user_profile/dev` - user_profiles service configs in dev profile
Response:
```
{
  "name": "user_profile",
  "profiles": [
    "dev"
  ],
  "label": null,
  "version": "cc5ba8578b63f9172093e4dd22753b3c43884ceb",
  "state": "",
  "propertySources": [
    {
      "name": "https://github.com/shivamlc/ai-news-platform-config.git/user_profile/application-dev.yml",
      "source": {
        "spring.application.name": "user_profile (dev)"
      }
    },
    {
      "name": "https://github.com/shivamlc/ai-news-platform-config.git/user_profile/application.yaml",
      "source": {
        "spring.application.name": "user_profile (default)"
      }
    }
  ]
}
```
- `http://localhost:8071/user_profile/prod` - user_profiles service configs in prod profile
Response:
```
{
  "name": "user_profile",
  "profiles": [
    "prod"
  ],
  "label": null,
  "version": "cc5ba8578b63f9172093e4dd22753b3c43884ceb",
  "state": "",
  "propertySources": [
    {
      "name": "https://github.com/shivamlc/ai-news-platform-config.git/user_profile/application-prod.yml",
      "source": {
        "spring.application.name": "user_profile"
      }
    },
    {
      "name": "https://github.com/shivamlc/ai-news-platform-config.git/user_profile/application.yaml",
      "source": {
        "spring.application.name": "user_profile (default)"
      }
    }
  ]
}
```
- `http://localhost:8071/user_profile/qa` - user_profiles service configs in qa profile
- `http://localhost:8071/user_profile/default` - user_profiles service configs in default profile

# Other notes
- Config server reads configs for client micro-services from config git repo.
- Each client service env specific configs can be defined in service specific dir (like /user_profile) in the config repo or all env specific configs for all services can be defined under root dir in config repo.
- Config server can have diff application properties in diff env. Here we have 4 env: default, dev, qa , prod. 
- For each env, config server can read configs from separate config repos. In our case, we have one repo for all envs.
- In our current setup, for every profile, config server will load all configs for all services (declared using search paths) for all envs. If we had diff config repo for each env, and each config repo had configs for services only for that particular env, then for each profile, config server would pull up profile specific env vars for every service.
- On startup, config server, clones config repo locally.