# ─── STAGE 1: BUILD ───────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests
RUN echo "=== WAR files found ===" && find /app/target -name "*.war" -type f

# ─── STAGE 2: RUNTIME ─────────────────────────────────────
FROM tomcat:10.1-jdk17-openjdk-slim
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY --from=builder /app/target/helloworld.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
