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
- Whenever the endpoints below are accessed by microservice, config server pulls latest configs from config repo instead of pulling configs from local cache.
- Microservices hit the endpoints below at the time of service startup.

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

# Encryption and Decryption of properties from config repo
- Get an encryption key (rsndom key or generated online, eg: https://generate-random.org/encryption-keys)
- Provide encryption key in application.yaml (hardcoded or thru env var)
- This encryption key is used to encrypt plain text values of properties in config repo and same key is used to decrypt encrypted value at the config server end. This is explained below:
- Say, 'user_profile' service has a property called, 'user_password' in application.yml of user_profile in config repo.
- First, get encrypted value of 'user_password' by sending POST request to `https://<config_server_address>:<port>/encrypt` and add the the value of 'user_password' as raw text in request body of this post request. The response will be a encrypted value of 'user_password'.
- In config repo, replace actual value of user_profile with encrypted value of 'user_password' in the following format: "{cipher}<encrypted_value_of_user_password>" 
- {cipher} denotes that value in "" is not string but an encrypted value of some plain text value.
- Send POST request to `https://<config_server_address>:<port>/decrypt` and add the encrypted value of 'user_password' as raw text in request body of this post request to get the plain text value of 'user_password'.

# Refresh of configurations at runtime
- How to refresh configuration properties in micro-services w/o restarting micro-services instances?
- For this, its important that individual micro-services have spring boot actuator dependencies defined in their pom.xml
- The micro-service whose configurations depend on config server, must have config properties defined using `@ConfigurationProperties` annotated Dto 
- Enable actuator endpoints in the microservice, by adding the following in application.yaml. We expose actuator refresh endpoint by doing so
```
management:
  endpoints:
    web:
      exposure:
        include: "*" # This exposes all Spring Boot Actuator endpoints over HTTP (e.g., /actuator/health, /actuator/info, etc.).
```
- The actuator refresh endpoint is used to refresh config properties in microservices. Since, microservices by themselves connect to config server only at service startup.
- hit `https://<microservice_server_address>:<port>/actuator/refresh` and this will refresh config properties in the microservice w/o restarting the service.

- There are drawbacks of this approach. This approach is not scalable. Need to manually hit actuator endpoint of micro-service to refresh configs. A micro-service can have mutiple instances and there can be 100s of microservices. Alternative approach - use of Spring Cloud Bus


## Spring Cloud Bus
### Client microservice updating configs for all other microservices - Case 1
- Project in Spring Cloud
- Links all nodes of a distributed system with a lightweight message broker and is used to broadcast changes like config changes.
- It links all instances of all microservices through message broker like kafka or rabbit mq.
- Then config changes through actuator can be propagated to all instances of microservices easily instead of manually updating each micro-service for config changes by calling microservice's `actuator/refresh` endpoint.
- To use Spring cloud bus, first install a message broker like RabbitMQ using docker: `# latest RabbitMQ 4.x
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:4-management`
- Then add the following "Spring for Rabbit MQ" Spring Cloud dependency, in all client micro-services pom.xml: 
- This is needed as well: - Add Spring Cloud Bus dependency in pom.xml of all client-micro services.
`    
    <dependency>
      <groupId>org.springframework.amqp</groupId>
      <artifactId>spring-rabbit-test</artifactId>
      <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-amqp</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-stream-binder-rabbit</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-bus</artifactId>
    </dependency>
`
- If not already done, enable the following actuator path in client micro-services: `busrefresh`
- In the properties.yaml of client microservices, add the following rabbitMQ properties so that they can connect to RabbitMQ
```
rabbitmq:
    host: "localhost"
    port: 5672
    username: "guest" #default username
    password: "password" # password
```
- Now,  hit `actuator/busrefresh` endpoint of any microservice, and the new config changes will appear in all microservices.
- This is beacause, when rabbitMQ sees a config change in config server, it propagates the config change to all micro-services connected to it.
- Drawback of using Spring Cloud Bus and RabbitMQ - `actuator/busrefresh` has to be hit manually or using CI/CD in at least one micro service

## Automated refresh of properties.
### Config Server updating configs for all other microservices - Case 2
### Following applies when config server runs on localhost
- Add the following "Spring for Rabbit MQ" Spring Cloud dependency, in config-server pom.xml: 
- Add Spring Cloud Bus dependency in pom.xml of Spring Cloud Server.
- The above dependencies are required to relay requests from webhook (or hookdeck) to Spring Cloud Server to Client microservices fetchings configs from the config server. This is shown below.
```
GitHub Webhook
      │
      ▼
   Hookdeck CLI / Cloud
      │
      ▼
POST http://localhost:8888/actuator/busrefresh
      │
      ▼
Spring Cloud Config Server
      │
      │  Publishes event to RabbitMQ (Cloud Bus)
      ▼
RabbitMQ Exchange / Queue
      │
      ▼
Subscribed Microservices (Spring Cloud Bus client)
      │
      ▼
Refresh Configuration (/refresh)

```
- Use webhook from Github/ADO or wherever config repo is hosted.
- Since config server is hosted locally, we cant send webhook requests to localhost directly. We need a middle layer/broker to facilitate webhook requests to localhost.
- Use `https://console.hookdeck.com/` as the broker.
- Using Webhooks (in Github or any provider where config repo is)
- Make sure that `actuator/busrefresh` is enabled in config server
```
management:
  endpoints:
    web:
      exposure:
        include: "*"
``` OR
```
management:
  endpoints:
    web:
      exposure:
        include: "health,info,busrefresh"
```
- Add rabbitMQ properties in application.yaml.
```
rabbitmq:
    host: "localhost"
    port: 5672
    username: "guest" #default username
    password: "password" # password
```
- Install HookDeck locally: `https://hookdeck.com/docs/cli#installation`
- Set up HookDeck project with new connection and transformation using the following steps on HookDeck dashboard or use HookDeck CLI (not covered here):

- Go to HookDeck dashboard (https://dashboard.hookdeck.com/events)
- Create new organisation and project
- Select the project and create new connection with some suitable <connection_name>.
- Select 'Github' as event source. Since we want any changes to config-repo in github to to trigger the webhook in github. This github webook will be our event source. Provide any suitable "source name". 
- Select 'CLI' as event source, since we want hookdeck to send events to cloud config server running locally. Provide any suitable "destination name". Procide CLI path as : `/actuator/busrefresh` since this is the config server endpoint that needs to be hit. 
- Define Connection rules (optional). You must define Transformation rule to make sure hookdeck send api request payload accepted by Spring Cloud config server. Use the following transformation rule. Make sure that body is 'null':
```
// transformer.js
addHandler('transform', (request, context) => {
  // Always send an empty JSON body to Spring Cloud Bus
  return {
    ...request,
    body: null,                    // required by /busrefresh
    headers: {
      ...request.headers,
      'Content-Type': 'application/json' // ensure correct header
    }
  };
});
```
- Run the transformation and then Save the transformation changes.
- Save the connection.
- Once the connection is created, Hookdeck will provide a URL that must be used by Github Webhook. A url like: ```https://hkdk.events/mp4o2s1cgdg9vx```
- In the config repo on github, Go to Settings -> Webhook -> Add Webhook -> Select Payload URl as ```https://hkdk.events/mp4o2s1cgdg9vx``` -> Content type (application/json) -> Enable SSL verification -> Push event -> Add Webhook confirmation. 
- After webhook is setup, go to the local terminal and run following commands (reuires hookDeck to be installed locally before running following commands.):
```bash
hookdeck login
```

```bash
hookdeck listen [PORT] <connection_name>
```
Replace [PORT] with port number of config server runnung locally. <connection_name> is the name provided in previous step.
- Any changes pushed to config repo will create events, and will be visible on hoockdeck deashboard and the local terminal running the hookdeck connection.

### Following applies when config server does not run on localhost
- - Add the following "Spring for Rabbit MQ" Spring Cloud dependency, in config-server pom.xml: 
- Add Spring Cloud Bus dependency in pom.xml of Spring Cloud Server.
- The above dependencies are required to relay requests from webhook to Spring Cloud Server to Client microservices fetchings configs from the config server. This is shown below.
```
GitHub Webhook
      │
      ▼
      │
      ▼
POST http://<config_server_address>:8071/actuator/busrefresh
      │
      ▼
Spring Cloud Config Server
      │
      │  Publishes event to RabbitMQ (Cloud Bus)
      ▼
RabbitMQ Exchange / Queue
      │
      ▼
Subscribed Microservices (Spring Cloud Bus client)
      │
      ▼
Refresh Configuration (/refresh)

```
- Use webhook from Github/ADO or wherever config repo is hosted.
- Make sure that `actuator/busrefresh` is enabled in config server
- Add rabbitMQ properties in application.yaml.
```
rabbitmq:
    host: "localhost"
    port: 5672
    username: "guest" #default username
    password: "password" # password
```
-  In the config repo on github, Go to Settings -> Webhook -> Add Webhook -> Select Payload URl as ```http://<config_server_address>:8071/actuator/busrefresh``` -> Content type (application/json) -> Enable SSL verification -> Push event -> Add Webhook confirmation.
- This should start sending events to config server when changes are pushed to config repo.  


## Summary of Config updates ( by Client Service or Config Server)
### 
1️⃣ Config propagation from Config Server → all client services

Goal: When a property changes in the Config Server, all clients automatically refresh.

What you need:

Config Server: Spring Cloud Bus + RabbitMQ (or Kafka)

Publishes change events when /actuator/busrefresh is called.

Clients: Spring Cloud Bus + RabbitMQ

Subscribes to bus events and triggers @RefreshScope beans to reload config.

Dependencies: Both Config Server and clients need:
```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-stream-binder-rabbit</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-bus</artifactId>
</dependency>

```
(spring-rabbit-test is only for testing)

2️⃣ Client → other clients propagation

Goal: If a single client service wants to propagate its own config changes to other microservices (not just from Config Server), you still use Spring Cloud Bus + RabbitMQ on that client.

How it works:

This client publishes a RefreshRemoteApplicationEvent or custom event on the bus.

Other clients receive the event and refresh their config automatically.

So yes, in this case:

Publishing client: Bus + RabbitMQ

All receiving clients: Bus + RabbitMQ

In this Scenario: Client → other clients propagation

One client service updates some configuration or triggers an event.

That client publishes a RefreshRemoteApplicationEvent (or custom event) on Spring Cloud Bus.

All other clients subscribed to the bus receive it and refresh.

Who needs Bus + RabbitMQ?

Publishing client → needs Bus + RabbitMQ

All receiving clients → need Bus + RabbitMQ

Config Server?

Not involved in this propagation. Bus + RabbitMQ on the Config Server is only required for Config Server → client propagation.


### Key points

Spring Cloud Bus is the event transport layer, RabbitMQ is the message broker.

Bus uses RabbitMQ to propagate refresh events. Without RabbitMQ (or Kafka), Bus cannot deliver events.

Every service that wants to either publish or listen for refresh events must include Bus and RabbitMQ dependencies.

You don’t need Bus + RabbitMQ on services that don’t care about dynamic config updates.

Scenario comparison
Use Case	Config Server	Clients
Config Server → clients	Bus + MQ	Bus + MQ
Client → other clients	Not required	Bus + MQ on all clients