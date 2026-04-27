Tags: [[_My_projects]]
#MyProjects 

# Preparing files
Terraform prepares the following files and saves them on the localhost:
- `values.yaml` for Helm charts:
	- `helm_charts/airflow`
	- `helm_charts/mlflow_setup`
	- `helm_charts/spark_thrift_server`
	- `helm_charts/hive_metastore`
- `create_k8s_secrets.sh` - Script preparing Kubernetes namespaces and secrets.

When using code from the prod repo to run applications on AKS, Terraform additionally creates:
- Dockerfile for building an image for interacting with AKS: `interacting.aks.Dockerfile`

Templates of those files are in the `terraform/teplate_files` folder and Terraform interpolates them (inserts into them values of variables).