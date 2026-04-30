Tags: [[_kind]] [[__Cloud]], [[__DevOps]], [[__Distributed_computing]], [[__Infrastructure_Engineering]] [[_My_projects]]
#kind #Cloud #DevOps #DistributedComputing #DataEngineering #MyProjects 

# Introduction
This is a guide for how to set up all the infrastructure needed to run the code from this repo - [link](https://github.com/bulka4/data_and_ml_platform_kind) on a kind cluster for development.

We assume here that we already have:
- Azure account
- Terraform, Docker and kind installed
# Run Terraform code
Run Terraform code to prepare cloud resources ([[Data and ML platform project - Cloud resources - Dev|link]]) and files ([[Data and ML platform project - Preparing files with Terraform|link]]) which will be saved on the host.
## Prepare variables (optional)
If we want, we can modify the `terraform.tfvars` file and assign there values to the variables. We can leave the default values.
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
# Starting the cluster
- Run this command:
```bash
# Run this from the repo root folder
kind create cluster --name data-platform --config kind-config.yaml
```
- Copy the `.kube` folder (usually located at `C:\Users\username`) into the repo root folder (so it can be copied into the image we build in the next step)
- Build and run the image for interacting with kind ([[Data and ML platform project - Docker image for interacting with AKS|link]]):
```bash
# Run this from the repo root folder
docker build -t interacting-kind -f interacting.kind.Dockerfile .
docker run -it --rm interacting-kind bash
```
# (Optional) VS Code for code development on Kubernetes
If we want to use VS Code to connect to Kubernetes pods and be able to modify files there and run commands in a terminal, we need to additionally modify the kubeconfig file to allow VS Code to connect to the Kubernetes cluster:
- Kubeconfig file is usually located at `C:\Users\username\.kube\config`)
- We need to modify it and change the IP address from `0.0.0.0` to `127.0.0.1` in the `clusters.cluster_name.server` field, for the kind cluster.
# Cleanup
How to clean up resources when we are done.

Cleanup of Docker images:
```bash
# remove all containers
docker rm $(docker ps -aq)

# remove all images
docker rmi $(docker image ls -aq)

# remove build cache
docker image prune -a
docker builder prune -a

# remove everything (images, containers, cache, volumes)
docker system prune --all --volumes
```

Delete the kind cluster:
```bash
kind delete cluster --name data-platform
```
# Prepare images and Kubernetes secrets
From inside of the image for interacting with Kubernetes:
- Run the `/bin/sh /root/create_k8s_secrets.sh` command
	- To create Kubernetes namespaces and secrets we will be using
- Run commands from the `/root/dockerfiles/build_and_load.sh` script on the host (run them outside of the image for interacting with kind. They require to use Docker)
	- It builds Docker images and loads them to kind, so they can be used to run pods
# Installing helm charts
- Install git-sync (optional) ([[Data and ML platform project - Making code available in pods|link]])
  ```bash
	# Execute below commands from the helm_charts/git_sync folder
	helm -n git-sync install git-sync . &
  ```
- Install Airflow ([[Data and ML platform project - Workflows orchestrated by Airflow|link]])
	```bash
	# Execute below commands from the helm_charts/airflow folder
	helm dependency update
	helm -n airflow install airflow . &
	```
- Install Spark Thrift Server ([[Data and ML platform project - Spark Thrift Server setup|link]])
	```bash
	# Execute below commands from the helm_charts/spark_thrift_server folder
	helm -n spark install spark . &
	```
- Install MLflow tracking server ([[Data and ML platform project - MLOps with MLflow|link]])
	- And also service account used by the `mlflow_project` helm chart
  ```bash
	# Execute below commands from the helm_charts/mlflow_setup folder
	helm -n mlflow install mlflow . &
  ```
- Install Prometheus and Grafana ([[Data and ML platform project - Monitoring|link]])
	```bash
	# Run this from the helm_charts/prometheus_grafana folder
	helm dependency update
	helm -n prometheus install monitoring . &
	```
	
	Get Grafana 'admin' user password by running:
	```bash
	kubectl -n prometheus get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
	```
# Installing Kubernetes operators
- Install Spark Operator (more details here - [[Data and ML platform project - Spark Operator setup|link]])
	- It is needed when making predictions with ML models and saving them in the Iceberg catalog, for example in the scripts:
		- `apps/airflow/dags/make_predictions/make_predictions_spark_operator.py`
  ```bash
	helm repo add spark-operator https://kubeflow.github.io/spark-operator
	helm repo update
	
	helm install spark-operator spark-operator/spark-operator -n spark \
	--set sparkOperatorVersion=v1beta2-2.1.0-3.5.0 \
	--set spark.jobNamespaces={spark} \
	--set webhook.enable=true \
	--set webhook.enableCertManager=false \
	--set webhook.generateSelfSignedCert=true
  ```