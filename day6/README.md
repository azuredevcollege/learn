# Day 6 Containerization

## Welcome

This day is about getting you started with containers. We will touch the following topics:

- Docker
- Container Basics
- Docker Objects
- Container Images and Registries
- Azure Container Services (like Azure Container Registry and have a first glance at the AZure Kubernetes Service)

## Challenges

- [Challenge 0: Prerequisites](./challenges/challenge0.md) (~20 min)
- [Challenge 1: Docker 101](./challenges/challenge1.md) (~30 min)
- [Challenge 2: Container 101](./challenges/challenge2.md) (~30 min)
- [Challenge 3: Docker Objects](./challenges/challenge3.md) (~30 min)
- [Challenge 4: Image and Registry](./challenges/challenge4.md) (~30 min)
- [Challenge 5: Azure Container Services](./challenges/challenge5.md) (~30 min)
- [Challenge 6: Self-learning](./challenges/challenge6.md)

## Goal

The main goal of the Day 6 is basically building _Linux Container_ and _Docker_ knowledge. The day will gradually guide you from the fundamentals to how to build Docker images.

At the end of the day you will have all the information related to running containers on production systems.

### Detailed Agenda

To reach today's goal we have split the schedule into several info slots that guide through the different topics. Each info slot is accompanied by a corresponding challenge that gives you the opportunity to get hands-on experience on the different topics. 

Here you find a list of the different info slots and what to expect from them:

#### Info Slot 1: Docker 101

- What is Docker?
  - Linux Container Concept (LXC, Kernel, Namespaces, Cgroups)
  - Docker history
  - Container and Image
  - Container vs VM
- Docker CLI and Basics
  - How to use CLI? (Help, version, cli not equals to daemon, management sub command)
  - Version, info
  - Basics (Name, ID)
  - How to run Docker Containers (docker run, start, stop, delete, ls)
  - Most used options (rm, -it etc.)
  - Detach, Active, Task Containers
  - Exec (Executing commands inside Containers)

#### Info Slot 2: Container 101

- Docker Container Basics
  - Theory (one app one container)
  - Union File System
  - Copy on Write
  - Container Life cycle (cattle vs pet)
  - Stdin, Stdout, Stderr
  - PIDs (Stats and Top)
  - Consumption Limits
  - Environment Variables

#### Info Slot 3: Docker Objects

- Batteries included but removable
- Docker Volume (Volume drivers, Bind Mounts)
- Docker Network (basics, drivers, port publish)

#### Info Slot 4: Image and Registry

- Image Basics
  - Image naming scheme and tags
  - Layers
  - Image pull, push
- Registry
  - What is an image registry?
  - Docker hub (Official Images, non-official images)
  - Repository
  - Azure Container Registry
- Image Creation
  - Dockerfile (Instruction, format)
  - ADD vs. COPY - ENTRYPOINT vs. CMD
  - Exec vs. Shell form
  - Multi-stage builds and build cache
  - Build ARG
  - Docker Commit - Docker save/load

#### Info Slot 5: Azure Container Services

- Container Services on Azure
  - Container Instances
  - App Service
  - Batch
  - Azure Service Fabric
  - Azure Red Hat OpenShift
  - Azure Container Registry (ACR)
  - Azure Kubernetes Service (AKS)
