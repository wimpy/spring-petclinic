# Spring PetClinic Sample Application [![Build Status](https://travis-ci.org/wimpy/spring-petclinic.png?branch=master)](https://travis-ci.org/wimpy/spring-petclinic/)
This is a fork of [the Spring PetClinic project](https://github.com/spring-projects/spring-petclinic) to show how to deploy an application [using Wimpy](https://wimpy.github.io/docs/).
Every push/merge to this repository ends up in Travis deploying the application.

## Configuration
The deploy folder contains the deployment configuration where we setup the basic Wimpy configuration

```yaml
- hosts: localhost
  connection: local
  vars_files:
    - "{{ playbook_dir }}/{{ wimpy_deployment_environment }}.yml"
  vars:
    # Application name
    wimpy_application_name: "spring-petclinic"
    # Port where our application is listening for requests
    wimpy_application_port: 8080
    # Endpoint where actuator exposes the health check
    wimpy_aws_elb_healthcheck_ping_path: "/manage/health"
  roles:
    - role: wimpy.environment
    - role: wimpy.build
    - role: wimpy.deploy

```

Since we want to have different configuration values depending on the environment where we deploy, we load a different config file based on the `wimpy_deployment_environment` parameter.
We may store secrets in these config files, so we have encrypted them using Ansible Vault.
The password for Ansible Vault is passed in the .travis.yml file as an encrypted environment variable.

## Continuous Deployment
The [deploy folder](deploy) also contains a [deploy.sh](deploy/deploy.sh) script that gets executed in Travis for every merge/push to `master`.
Although we don't recommend it, you can execute the script from your terminal to deploy without going through Travis.

## Docker
Wimpy will deploy the application using Docker, so we need to provide [a valid Dockerfile](Dockerfile) to build an image for the application.
We make use of Docker multi stage build system to first generate the application JAR file using Maven, and then build the application Docker image using a minimal alpine based image with Java8.
 
```
FROM maven:3.5-jdk-8-alpine as BUILD

COPY . /usr/src/app
RUN mvn -f /usr/src/app/pom.xml clean package

FROM openjdk:8-jdk-alpine

COPY --from=BUILD /usr/src/app/target/*.jar /opt/app.jar
WORKDIR /opt
CMD ["java", "-jar", "app.jar"]

```

That [Dockerfile](Dockerfile) is valid for any Maven application that runs on Java8.
You can test the Docker image locally in your computer

```bash
$ docker build -t spring-petclinic .
$ docker run --rm -p 8080:8080 spring-petclinic
```
