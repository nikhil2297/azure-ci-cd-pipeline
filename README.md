---

# Node.js API with Docker, Azure Container Registry, and Azure Pipeline

This project demonstrates how to build and deploy a Node.js API using Docker, Azure Container Registry (ACR), and Azure Web App Service. Additionally, it showcases how to set up a CI/CD pipeline using Azure Pipelines to automate the process of building Docker images and deploying them to ACR with each GitHub commit.

## Table of Contents
- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [1. Local Development](#1-local-development)
  - [2. Docker Setup](#2-docker-setup)
  - [3. Azure Container Registry](#3-azure-container-registry)
  - [4. Azure Web App Service](#4-azure-web-app-service)
  - [5. Azure Pipeline Setup](#5-azure-pipeline-setup)
  - [6. Local Machine as Pipeline Agent](#6-local-machine-as-pipeline-agent)
- [Pipeline Configuration (YAML)](#pipeline-configuration-yaml)
- [Conclusion](#conclusion)

## Project Overview
This project is a simple Node.js API that is containerized using Docker. The Docker image is pushed to Azure Container Registry (ACR) and deployed to an Azure Web App Service for hosting. An Azure Pipeline is configured to automate the CI/CD process, building a new Docker image and pushing it to ACR every time a new commit is made to the GitHub repository.

## Prerequisites
- [Node.js](https://nodejs.org/) installed on your local machine
- [Docker](https://www.docker.com/) installed and configured
- An [Azure account](https://portal.azure.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- [Git](https://git-scm.com/) for version control
- [Azure DevOps](https://dev.azure.com/) account

## Setup Instructions

### 1. Local Development
1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Run the API locally:
   ```bash
   npm start
   ```

### 2. Docker Setup
1. Create a `Dockerfile` in the root of your project with the following content:
   ```Dockerfile
   FROM node:14
   WORKDIR /app
   COPY package*.json ./
   RUN npm install
   COPY . .
   EXPOSE 3000
   CMD ["npm", "start"]
   ```

2. Build the Docker image:
   ```bash
   docker build -t your-app-name .
   ```

3. Run the Docker container:
   ```bash
   docker run -it -p 3000:3000 your-app-name
   ```

### 3. Azure Container Registry
1. Log in to Azure:
   ```bash
   az login
   ```

2. Create a resource group (if you don’t have one already):
   ```bash
   az group create --name myResourceGroup --location eastus
   ```

3. Create an Azure Container Registry:
   ```bash
   az acr create --resource-group myResourceGroup --name yourRegistryName --sku Basic
   ```

4. Log in to your Azure Container Registry:
   ```bash
   az acr login --name yourRegistryName
   ```

5. Tag your Docker image:
   ```bash
   docker tag your-app-name:latest yourRegistryName.azurecr.io/your-app-name:latest
   ```

6. Push the image to Azure Container Registry:
   ```bash
   docker push yourRegistryName.azurecr.io/your-app-name:latest
   ```

### 4. Azure Web App Service
1. Create an Azure Web App for Containers:
   ```bash
   az webapp create --resource-group myResourceGroup --plan myAppServicePlan --name your-webapp-name --deployment-container-image-name yourRegistryName.azurecr.io/your-app-name:latest
   ```

2. Configure the Web App to use the ACR image:
   - Navigate to **Azure Portal** > **App Services** > Your Web App > **Container Settings**.
   - Select **Azure Container Registry**.
   - Choose your container registry and the appropriate image tag.
   - Click **Save**.

### 5. Azure Pipeline Setup
1. Create a new Azure DevOps organization and a new project.
2. Navigate to **Pipelines** > **Create Pipeline**.
3. Select **GitHub** as the source and authenticate your GitHub account.
4. Set up a new pipeline to build and push your Docker image:
   - During pipeline setup, configure the pipeline to push the image to Azure Container Registry.

### 6. Local Machine as Pipeline Agent
Azure’s free-tier no longer allows the use of hosted agents for pipelines, so you need to configure your local machine as an Azure DevOps agent.

1. Follow the Azure DevOps documentation to install the agent on your local machine: [Set up self-hosted agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops).
2. Register the agent with your Azure DevOps organization.
3. Use the pool with the local agent in your pipeline YAML file.

## Pipeline Configuration (YAML)

Here’s the final `.yaml` pipeline configuration that builds a Docker image and pushes it to Azure Container Registry on every GitHub commit:

```yaml
trigger:
- main

resources:
- repo: self

variables:
  dockerRegistryServiceConnection: '99a00863-7ea2-4b3f-b19f-5d75d836f903' # Your service connection ID
  imageRepository: 'your-app-name'
  containerRegistry: 'yourRegistryName.azurecr.io'
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  tag: '$(Build.BuildId)'
  vmImageName: 'ubuntu-latest'

stages:
- stage: Build
  displayName: Build and push stage
  jobs:
  - job: Build
    displayName: Build
    pool:
      name: lohar-pool # Custom pool using local machine as agent
    steps:
    - task: Docker@2
      displayName: Build and push an image to container registry
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
        tags: |
          $(tag)
```

## Conclusion
With this setup, your Node.js API is containerized and deployed using Azure Web App Service, and your Azure DevOps pipeline automates the CI/CD process. Every GitHub commit triggers a pipeline that builds and pushes the Docker image to Azure Container Registry.