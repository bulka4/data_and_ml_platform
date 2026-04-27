Tags: [[_kind]] [[__Cloud]], [[__DevOps]], [[__Distributed_computing]], [[__Infrastructure_Engineering]]
#kind #Cloud #DevOps #DistributedComputing #DataEngineering 

# Introduction
This document describes how setting up a kind cluster works in this repo - [link](https://github.com/bulka4/data_and_ml_platform_kind).
# Starting the cluster
We start the cluster using this command:
```bash
# Run this from the repo root folder
kind create cluster --name data-platform --config kind-config.yaml
```
# Kubeconfig file
A kubeconfig file, needed to interact with the cluster, is saved in the `%USERPROFILE%\.kube\config` file (`%USERPROFILE%` is user's folder, for example `C:\Users\<user-name>`) automatically by kind when we create a cluster.
# Docker image for interacting with the kind cluster
We can create a Docker image with prepared tools for interacting with the kind cluster. 

The image will include:
- `kubectl`
- `helm`
- Scripts for:
	- Building Docker images and loading them to kind (more info in the next section 'Docker images to be used for deploying pods')
	- Creating Kubernetes namespaces and secrets

In order to do this:
- Copy the `.kube` folder (usually located at `C:\Users\username`) into the repo root folder (so it can be copied into the image we build in the next step)
- Build and run the image for interacting with kind ([[Data and ML platform project - Docker image for interacting with AKS|link]]):
```bash
# Run this from the repo root folder
docker build -t interacting-kind -f interacting.kind.Dockerfile .
docker run -it --rm interacting-kind bash
```
# Docker images to be used for deploying pods
In the image for interacting with kind we create a script `/root/dockerfiles/build_and_load.sh` for building Docker images and loading them to kind, so they can be used for deploying pods.

We need to run commands from this script on the host, outside of the image for interacting with Kubernetes (because it requires Docker).

We need to use `image_pull_policy="IfNotPresent"` option when creating a pod to use a local image instead of pulling one from a remote registry.