# Use an official OpenJDK runtime as a parent image
FROM eclipse-temurin:17-jre

# Set a directory for the app
WORKDIR /app

# Copy the jar produced by Maven
COPY target/*.jar app.jar

# Expose any port your app listens on
EXPOSE 8088

# Run the jar file
ENTRYPOINT ["java","-jar","/app/app.jar"]
