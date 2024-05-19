# Jenkins CI/CD Pipeline with Docker and GitHub

This repository demonstrates a Jenkins pipeline implementation for achieving continuous integration and continuous deployment (CI/CD) using Docker and GitHub.

## Introduction

The CI/CD pipeline provided here allows you to automate the process of building, testing, and deploying your application whenever changes are pushed to the GitHub repository. Jenkins, an open-source automation server, is used as the orchestrator for the pipeline. Docker, a popular containerization platform, is utilized to manage the deployment process.

## Prerequisites

Before setting up the pipeline, ensure that you have the following prerequisites:

1. An Linode Linux machine with Jenkins, Git, and Docker installed.
2. A GitHub repository containing your application code and Dockerfile.

## Installation Instructions

### Installing Jenkins

### Installing Docker

### Installing Git

### Additional Configuration

To allow Jenkins to interact with Docker, execute the following command:

```bash
sudo usermod -aG docker jenkins
```
After executing the above command, restart Jenkins:

```bash
sudo systemctl restart jenkins
```

## Pipeline Overview

The Jenkins pipeline is triggered by a webhook configured on the GitHub repository. Whenever a developer pushes changes to the repository, the pipeline is initiated, and the following steps are executed:

1. The pipeline checks if there is a running Docker container for the application.
2. If a container is running, the pipeline copies the updated files from the Jenkins workspace to the running container, ensuring the changes are immediately reflected.
3. If no running container is found, the pipeline builds a new Docker image using the code from the GitHub repository and deploys it as a new container on Linode Linux machine.
4. The deployed application can then be accessed on the target machine through the specified port.

## Getting Started

To get started with this CI/CD pipeline, follow the steps below:

1. Set up Jenkins, Git, and Docker on your machine.
2. Provide Jenkins with a GitHub credential (token):
   - Generate a GitHub personal access token with the appropriate scopes (repo, webhook, etc.).
   - In Jenkins, go to "Manage Jenkins" > "Manage Credentials"> "Global credentials (unrestricted)".
   - Add a new credential of type "Secret text" or "Secret file" and enter your GitHub token.
   - Save the credential. 
3. Configure Jenkins by accessing its web interface.
4. Create a new Jenkins job and configure it as follows:
   - Set the job type to "Freestyle Project".
   - Connect it to your GitHub repository (https://github.com/njanfang/testcicd.git) and configure the webhook.
   - Select "GitHub hook trigger for GITScm polling" as the build trigger.
   - Add an "Execute Shell" build step to the pipeline and use the following code:
   ```bash
   #!/bin/bash

    container_id=$(docker ps --filter "status=running" --format "{{.ID}}")

    if [ -n "$container_id" ]; then
    docker cp /var/lib/jenkins/workspace/testcicd/. "$container_id":/usr/share/nginx/html
    else
    docker build -t server /var/lib/jenkins/workspace/testcicd
    docker run -d -p 9090:80 server
    fi
    ```
Run the Jenkins job and verify the successful execution of the pipeline.

