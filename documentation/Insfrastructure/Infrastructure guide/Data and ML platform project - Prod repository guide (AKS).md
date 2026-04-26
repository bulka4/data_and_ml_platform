Tags: [[_My_projects]]
#MyProjects 

# Introduction
This is a guide for how to prepare infrastructure to deploy code from this repo - [link](https://github.com/bulka4/data_and_ml_platform_kind) on AKS for production.
# Run Terraform code
Run Terraform code to prepare cloud resources ([[Data and ML platform project - Cloud resources - Prod|link]]).
## Prepare variables
Create the `terraform.tfvars` file and assign there values to the variables. We can use for that the `terraform-draft.tfvars` file which is a draft showing what variables to set up.

We need to have big enough number of nodes for the AKS cluster and their size need to be big enough. Otherwise, we can have not enough computational power to run apps. It is recommended to leave the default values (they are a minimum to run this platform).
## Run the code
```bash
# execute from the terraform folder
terraform init # Only when running for the first time
terraform plan -out main.tfplan
terraform apply "main.tfplan"
```

Later, to destroy all the Azure resources:
```bash
# execute from the terraform folder
terraform plan -destroy -out main.destroy.tfplan
terraform apply "main.destroy.tfplan"
```
# Run an image for interacting with AKS
Run an image for interacting with AKS ([[Data and ML platform project - Docker image for interacting with AKS|link]]) using the `interacting.aks.Dockerfile` Dockerfile, connect to it and from that image perform all the next steps:
```bash
# execute from the repo root folder
docker build -t interacting-aks -f interacting.aks.Dockerfile . # build an image
docker run -it interacting-aks bash # run the container and connect into it
```

Cleanup for later:
```bash
docker rm $(docker ps -aq) # remove all containers
docker rmi $(docker image ls -aq) # remove all images
docker system prune --all --volumes # remove everything
```
# Build and push images to ACR
Build and push to ACR all the images using the `/root/dockerfiles/build_and_push.sh` script (we need to run commands from that script outside of the image for interacting with Kubernetes as they require to use Docker). Those are images we will be running in Kubernetes pods.
# Create namespaces and secrets
Run the `/bin/bash create_k8s_secrets.bash` command to create Kubernetes namespaces and secrets:
- For pulling images from ACR
- For Airflow to access Storage Account to save logs there
- For Airflow to connect to PostgreSQL metadata db
- For PostgreSQL deployment (to create a user and database used by Airflow)
# Install Airflow chart
```bash
# execute from the helm_charts/airflow folder
helm dependency update

helm install airflow . \
  -n airflow \
  -f values.yaml &
```
# Spark Thrift Server and Hive Metastore setup
- Install Helm chart:
```bash
# Execute below commands from the helm_charts/spark_thrift_server folder
helm dependency update
helm install spark-thrift-server .
```
# MLflow setup
- Create a secret with credentials to the MySQL backend store. That secret will be used when installing the 'MLflow setup' Helm chart:
```bash
kubectl create secret generic mlflow-mysql \
  --from-literal=root_password=mlflow \
  --from-literal=user_password=mlflow \
  -n mlflow
```
- Create a secret with an access key to a Storage Account:
```bash
kubectl create secret generic mlflow-sa \
  --from-literal=access_key=XXX\
  -n mlflow
```
- Install Helm chart:
```bash
helm dependency update
helm install mlflow ./helm_charts/mlflow_setup
```
