Tags: [[_My_projects]]
#MyProjects 

# Introduction
This document explains the Docker image for interacting with Kubernetes (AKS, kind).

Terraform creates a Dockerfile ([[Data and ML platform project - Preparing files with Terraform|link]]) which can be used to build an image from which we can interact with AKS and ACR through CLI using:
- Helm
- kubectl
- Azure CLI

From inside of that image we perform operations like:
- Building Docker images and pushing them to ACR
- Deploying Helm charts
- Interacting with Kubernetes pods (checking statuses, logs, connecting to them and executing CLI commands)
# Pushing Docker images to ACR
We can use the `/root/apps/build_and_push.sh` script from the image to build images needed for the platform and push them to ACR.
# Creating Kubernetes namespaces and secrets
The `/root/create_k8s_secrets.sh` script can be used to create Kubernetes namespaces and secrets we will be using later to run applications.
# Helm charts
In the `/root/helm_charts` folder we have all the Helm charts copied from the repository.
