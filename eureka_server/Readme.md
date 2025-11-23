# Service Discovery & Registration in Microservices

- How do microservices locate each other inside a network?
- How does a new service instance enter into the network?
- How load balance info is shared b/w microservice instances?

## Service communication in traditional apps

- if a service 1 depends on service 2, service 1 is called upstream service, service 2 is called downstream service.
- in traditional apps, service 1 needs to know the ip address/dns name of service 2 before it can communicate to service 2. No service discovery or load balancing involved.
- this approach works if we only have one instance of service 2. However, in cloud environment, it is common to have multiple instances of service. Each instance has its own ip address.
- also each instance/container is short lived and their ip addresses keep changing.
- in traditional load balancer design, there is a primary load balancer that has a routing table. when a client tries to access a service' s endpoint, traditional load balancer (tlb), looks at the request path from client to identify the service client need to connect to. TLB then fetches ip address of the concerned microservice from routing table forwards request to that ip address.
- In TLB approach, there is also a secondary TLB which becomes operaitonal in case primary TLB goes down.
- in this design, instances of MS have static ip addresses. Good for SOA based applications with small number of services running.
- Drawbacks of TLB:
  -- Limited horizontal scaling and license cost
  -- Single point of failure and centralised checkpoints
  -- IPs /configurations in routing tables are manually managed
- Complex in nature and not container friendly

## Service Discovery, Service Registration, Load Balancing in Cloud native apps

- involves tracking and storing info about all running services instances in a service registry.
- when a new instance is created, it should be refistered in registry. When it terminates, its removed from registry.
- two approaches : server side discovery and client side discovery.
- registry acknosledges the fact that there can be multiple instance of same service active simultaneaously.
- when service 1 needs to communicate to service 2, it gets ip address of service 2 from registry.
- load balancing strategy is employed to evenly distribute workload among multiple instances of same microservice.
