Tags: [[_My_projects]]
#MyProjects 

# Infrastructure
This platform runs on Kubernetes:
- AKS - cloud Kubernetes cluster for production
- kind - a local Kubernetes cluster for development

Additionally, we use cloud resources prepared by Terraform:
- When using kind for local development ([[Data and ML platform project - Cloud resources - Dev|link]]):
	- Azure Data Lake - Object data storage
	- Service Principal - For authentication when accessing Azure resources
- When using AKS in production ([[Data and ML platform project - Cloud resources - Prod|link]]):
	- Azure Data Lake - Object data storage
	- AKS - Kubernetes cluster
	- ACR - For storing Docker images
	- Service Principal - For authentication when accessing Azure resources
# Code development
In order to develop code ([[Data and ML platform project - Code development & testing scripts|link]]) which we will run on this platform, we can:
- Create a development pod using one of the prepared Helm charts
	- That pod will have prepared environment and we can mount to it code which we already developed
- Connect to the created pod so we can edit files in it and run shell commands using:
	- Interactive shell - Using the`kubectl exec -it` command, we get an access to a pod's shell session from our local computer's terminal
	- VS code - We can attach VS code to the created pod so we can see and edit its files and run shell commands from a terminal just like on a local computer
## Running code
To run all the code, for example:
- MLflow projects
- dbt models
- Spark jobs

There are two options:
- Run manually in a development pod:
	- Set up a development pod
	- Attach VS code to it
	- Edit files in the pod and run the code manually
- Orchestrate with Airflow
	- We can create an Airflow task which runs the code:
		- As a Kubernetes job
		- Or using Spark Operator if the code uses Spark
# Data warehouse
As a data warehouse we use Azure Data Lake Gen2 and Iceberg ([[Data and ML platform project - Data storage|link]]). Optionally we could use additionally Hive Metastore except for Iceberg. We don't do this currently but the code is prepared ([[Data and ML platform project - Hive Metastore setup|link]]).
# Workflow orchestration
For workflow orchestration we use Airflow. 
## Running Airflow tasks
Airflow runs tasks in the following way ([[Data and ML platform project - Airflow - How to build workflows|link]]):
- As a Kubernetes job
- For Spark jobs we can use either Spark Operator or a Kubernetes job

We create those Airflow tasks such that:
- Task finishes when the job finishes
- Wen job fails, then Airflow task fails as well

To specify what code to run and how to prepare a pod when running a task as a job or using Spark Operator, we provide a YAML manifest parametrized using Jinja templating.

Using Airflow we orchestrate:
- Building dbt models ([[Data and ML platform project - dbt with Airflow|link]])
- Running scripts for making and saving predictions using a ML model saved in a MLflow registry and Spark ([[Data and ML platform project - Making and saving predictions|link]])
- Running scripts for automatic ML model update when its performance drops using MLflow ([[Data and ML platform project - Automatic update of ML models based on their performance|link]])
	- We use here a conditional task which skips all the next, downstream tasks if model performance is still good
## Airflow deployment
We deploy Airflow using a custom Helm chart which is a modified version of the official chart. Thanks to that, each Airflow component runs in a separate pod and can be scheduled on any node in a cluster:
- Scheduler
- Webserver
- Workers
- etc.

PostgreSQL is used as a metadata database and is deployed separately in the same chart.

Also, to make DAGs code available for Airflow components, we can:
- Use git-sync (deployed using a separate Helm chart) which pulls code regularly
- Mount files from the host using a PV with a `hostPath`
# Data transformation
For data transformation we use Spark Thrift server ([[Data and ML platform project - Spark Thrift Server setup|link]]) (which is a long-running Spark driver) and dbt ([[Data and ML platform project - dbt setup|link]]).

In dbt we define SQL queries to run, Spark Thrift server executes them and saves in an Iceberg catalog (Thrift server is configured to save data in an Iceberg catalog by default).

Spark Thrift Server runs in a cluster mode with Kubernetes as a master, so each Spark worker can be run on a different node in the cluster and it runs in a pod prepared by Kubernetes.

It is deployed using our custom Helm chart.
## Running Spark jobs
There are two options for how we can run Spark jobs in a cluster mode (using Kubernetes as a master):
- As a Kubernetes job
- Using Spark Operator

For example, we run Spark jobs which makes predictions using a ML model and saves them in an Iceberg catalog ([[Data and ML platform project - Making and saving predictions|link]]).
# MLOps
We use MLflow for:
- Experiment tracking - keeping track of information about models we create, e.g. hyperparameters used or evaluation metrics
- Managing model registry - where we keep models saved and we can assign to them stages and aliases, e.g. "Stage", "Production".

Together with Airflow, Spark and dbt, it can be used for MLOps, that is:
- Training, evaluating and saving ML models ([[Data and ML platform project - Training, evaluating and saving ML models with MLflow|link]])
- Making and saving predictions ([[Data and ML platform project - Making and saving predictions|link]])
- Model performance monitoring ([[Data and ML platform project - ML model performance monitoring|link]])
- Automatic model update when its performance drops ([[Data and ML platform project - Automatic update of ML models based on their performance|link]])
## MLflow deployment
We deploy a remote MLflow Tracking server which all the MLflow scripts can talk to in order to save and read metadata and artifacts. 

It is deployed using our prepared Helm chart which runs:
- Tracking server as a Kubernetes deployment 
- PostgreSQL used as a metadata database as a separate Kubernetes deployment
# Monitoring
We use Prometheus and Grafana for monitoring. They are deployed using the official Helm chart.

Right now there is only basic monitoring provided out-of-box by the official chart which includes for example monitoring Kubernetes nodes (e.g. CPU and memory usage).

We can additionally add for example:
- Airflow workflows execution monitoring
	- DAG success/failure rate
	- task duration
	- retries
- Model performance monitoring
	- Get notification when model is being updated because its performance dropped