# File : Dockerfile
FROM openjdk:21-alpine

ARG JAR_FILE=target/scheduler-info-0.0.1-SNAPSHOT.jar

EXPOSE 8090
WORKDIR /opt/app

COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java","-jar","app.jar"]