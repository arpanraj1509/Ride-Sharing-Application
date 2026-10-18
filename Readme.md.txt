========================================================================
             UBER-STYLE REAL-TIME RIDE MATCHING SYSTEM
========================================================================

Author / Developer : [Your Name]
Repository         : https://github.com/[your-username]/ride-matching-system
Tech Stack         : Java, Spring Boot, Redis Geospatial, Apache Kafka,
                     MySQL, Docker, Docker Compose

------------------------------------------------------------------------
1. OVERVIEW
------------------------------------------------------------------------
This repository contains a high-performance, event-driven microservices
backend system that simulates real-time ride-matching and driver location
tracking—similar to Uber and Ola.

The system is designed to handle high concurrency and low-latency geospatial 
queries, ensuring riders are matched with nearby drivers within milliseconds.


------------------------------------------------------------------------
2. ARCHITECTURE & WORKFLOW
------------------------------------------------------------------------
+-------------------+      +--------------------+      +--------------------+
|  Driver / Rider   | ---> | Location Service   | ---> | Redis Geospatial   |
|   Client Apps     |      | (Spring Boot REST) |      | (In-Memory Index)  |
+-------------------+      +--------------------+      +--------------------+
                                     |                           |
                                     v                           v
                           +--------------------+      +--------------------+
                           |  Ride Service      | <--- | Apache Kafka       |
                           |  (Business Logic)  |      | (Event Streaming)  |
                           +--------------------+      +--------------------+
                                     |
                                     v
                           +--------------------+
                           | MySQL Database     |
                           | (Data Persistence) |
                           +--------------------+

Process Flow:
1. Active drivers stream their GPS coordinates (lat, long, driverId) 
   every 3 seconds to the Location Service.
2. The Location Service updates the Redis Geospatial Index (GEOADD).
3. When a rider requests a ride, the system triggers a radius search 
   (GEORADIUS) in Redis to fetch nearby available drivers instantly.
4. Kafka streams state change events (Requested, Accepted, En-Route, 
   Completed, Cancelled) asynchronously across microservices.


------------------------------------------------------------------------
3. TECH STACK & TOOLS
------------------------------------------------------------------------
- Core Backend: Java 17+, Spring Boot, Spring Data JPA, REST APIs
- In-Memory Cache / Geo Index: Redis (Geospatial)
- Event Streaming / Messaging: Apache Kafka, Apache ZooKeeper
- Database: MySQL
- Containerization & Tools: Docker, Docker Compose, Git, Postman


------------------------------------------------------------------------
4. KEY ENGINEERING HIGHLIGHTS
------------------------------------------------------------------------
- Why Redis Geospatial instead of Relational SQL?
  Relational databases using Haversine formulas (SQL ACOS/COS) experience 
  massive CPU bottlenecks during concurrent spatial searches. Redis stores 
  geohashes inside sorted sets (ZSETs), enabling sub-millisecond proximity 
  searches even under millions of updates.

- Decoupled Microservices:
  Uses Apache Kafka to process ride lifecycles asynchronously without 
  blocking main execution threads.


------------------------------------------------------------------------
5. REST API ENDPOINTS
------------------------------------------------------------------------
Location Service:
  POST   /api/v1/locations           - Update driver coordinates
  GET    /api/v1/locations/nearby    - Query drivers within radius
  DELETE /api/v1/locations/{id}      - Set driver offline (Remove from Geo Index)

Ride Service:
  POST   /api/v1/rides/request       - Request a new ride
  POST   /api/v1/rides/accept        - Accept a ride (Driver)
  PATCH  /api/v1/rides/{id}/status   - Update ride status (START, COMPLETE, CANCEL)


------------------------------------------------------------------------
6. HOW TO RUN THE PROJECT
------------------------------------------------------------------------
Prerequisites:
- Java JDK 17 or higher
- Maven
- Docker & Docker Compose

Step 1: Clone the repository
  git clone https://github.com/[your-username]/ride-matching-system.git
  cd ride-matching-system

Step 2: Start infrastructure using Docker
  docker-compose up -d

Step 3: Configure Database & Redis
  Verify host and port configurations in 'application.yml':
    - Redis: localhost:6379
    - MySQL: localhost:3306
    - Kafka: localhost:9092

Step 4: Build and launch the application
  mvn clean install
  mvn spring-boot:run


------------------------------------------------------------------------
7. LICENSE & AUTHOR
------------------------------------------------------------------------
Developed by Arpan Rajvanshi
