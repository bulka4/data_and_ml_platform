Tags: [[_My_projects]]
#MyProjects 

# Introduction
We can use the `interacting.kind.Dockerfile` Dockerfile to prepare an image for interacting with kind. In that image we will have:
- Helm
- kubectl

From inside of that image we perform operations like:
- Deploying Helm charts
- Interacting with Kubernetes pods (checking statuses, logs, connecting to them and executing CLI commands)
# Loading Docker images to kind
We can use the `/root/apps/build_and_push.sh` script from the image to build images and load them to kind which are needed to create pods.

We need to run commands from this script on the host as they requires Docker.
# Creating Kubernetes namespaces and secrets
The `/root/create_k8s_secrets.sh` script can be used to create Kubernetes namespaces and secrets we will be using later to run applications.
# Helm charts
In the `/root/helm_charts` folder we have Helm charts copied from the host which we can run on kind.