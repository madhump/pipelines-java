# ─── STAGE 1: BUILD ───────────────────────────────────────
# Use Maven + JDK 17 to compile and package the JAR
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first (Docker cache trick — explained below)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Now copy source and build
COPY src ./src
RUN mvn package -DskipTests

# ─── STAGE 2: RUNTIME ─────────────────────────────────────
# Use a slim JRE-only image — much smaller than the build image
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy only the JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the port your app runs on (change if different)
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
