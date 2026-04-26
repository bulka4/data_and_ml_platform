Tags: [[_My_projects]]
#MyProjects 

# Helm chart
We use the `helm_charts/mlflow_setup` Helm chart to:
- Run MLflow tracking server and a PostgreSQL used as a backend store
- Create a service account which will be used for pulling images from ACR when we will want to run a MLflow project in a new pod (outside of this chart, it doesn't run a MLflow project).
# PostgreSQL as a backend store
We use PostgreSQL as a backend store for MLflow Tracking Server. We deploy it using the official Docker image as a separate deployment in the same Helm chart.

For production it is recommended to use a managed PostgreSQL database as running databases on Kubernetes is problematic as described here - [[Kubernetes - Running databases]].
# Accessing MLflow Tracking server
We can access it through the URL: `localhost:5000`.
# Azure Storage Account as an artifact store
We use an Azure ADLS Gen2 as an artifact store.