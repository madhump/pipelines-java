# ─── STAGE 1: BUILD ───────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn package -DskipTests

# Show what was built — helps debug
RUN echo "=== JAR files found ===" && find /app/target -name "*.jar" -type f

# ─── STAGE 2: RUNTIME ─────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy ALL jars and rename
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
