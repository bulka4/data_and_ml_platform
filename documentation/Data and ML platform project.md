Tags: [[_My_projects]]
#MyProjects 

# Introduction
This platform can be used for:
- Data ingestion - Using Python scripts
- Data storage - Using Azure Data Lake Gen2 (object data storage)
- Distributed data transformation - Using Spark
- MLOps - Using MLflow:
	- Creating, validating and storing ML models
	- Experiment tracking (keeping track of information about models we create, e.g. hyperparameters used or performance metrics)
	- Automatic model update when performance drops

It is designed to be deployed on Kubernetes.

Technologies used:
- Containers and orchestration - Docker and Kubernetes
- IaC - Terraform
- Workflow orchestration - Airflow
- Data transformation - dbt, Spark
- Data storage - Iceberg, Azure Data Lake Gen2
- MLOps - MLflow
- Programming languages - Python, SQL
# Benefits of the tools used
Benefits of the tools used in this platform:
- Airflow - [[Data and ML platform project - Airflow - Benefits and key features]]
- dbt - [[Data and ML platform project - dbt benefits]]
- Spark enables partitioning data what has benefits described here - [[Data Engineering - Partition-based writes]].
- Iceberg - [[Iceberg - Benefits]]
	- Hive vs Iceberg comparison - [[Iceberg vs Hive]]
- MLflow - [[Data and ML platform project - MLflow - Benefits and key features]]
# Dev and prod repositories
This project consists of two repositories:
- Dev - [data_and_ml_platform_kind](https://github.com/bulka4/data_and_ml_platform_kind) 
- Prod - [data_and_ml_platform](https://github.com/bulka4/data_and_ml_platform) 

The dev repository is used for running the platform on kind, a Kubernetes cluster running in Docker on localhost.

The prod repository is used for running the platform on AKS (Azure Kubernetes Service) and using other cloud services.
## Code status
The dev repository contains all the features. The prod one, only a part of them.
# Infrastructure
Below sections and documents describe infrastructure setup, that is how do we set up all the tools which we then can use for developing applications.
## Infrastructure guide
A guide for how to set up infrastructure:
 - [[Data and ML platform project - Prod repository guide (AKS)]]
 - [[Data and ML platform - Dev repository guide - kind setup]]
## Accessing services UIs
We can access UIs of different services by using below URLs in a browser:
- Airflow UI - `localhost:8080`
- MLflow Tracking server UI - `localhost:5000`
- Grafana - `localhost:3000`
## Cloud resources
Below document explains:
- What cloud resources we set up
- How do we configure them
- How do we use Terraform for that

for both development on kind and production on AKS:
- [[Data and ML platform project - Cloud resources - Prod]]
- [[Data and ML platform project - Cloud resources - Dev]]
## Preparing files with Terraform
Terraform code except for creating cloud resources, it also prepares files on the localhost with proper values about created cloud resources.

More info can be found here - [[Data and ML platform project - Preparing files with Terraform]].
## kind cluster for local testing
Below document describes setting up a kind Kubernetes cluster for local testing before deploying on AKS:
[[Data and ML platform - Setting up a kind cluster]] 
## Docker image for interacting with Kubernetes
We can use a Docker image for interacting with:
- kind
- AKS 
- Other cloud resources

Below documents describes how this image works for both dev and prod:
- Prod - [[Data and ML platform project - Docker image for interacting with AKS]]
- Dev - [[Data and ML platform project - Docker image for interacting with kind]]

In that container we have prepared all the tools needed, like for example `kubectl`, Helm or Azure CLI.
## Code development
Those documents describe how to set up environment for developing code on Kubernetes:
- Using VS Code Kubernetes extension for this project - [[Data and ML platform project - VS Code Kubernetes extension setup for code development|link]] 
- Code development on Kubernetes general notes - [[Data and ML platform project - Code development setup|link]] 
## Making code available in pods
This document describes how we make code available in pods, i.e. either via git-sync or by cloning a git repo in an init container - [[Data and ML platform project - Making code available in pods]].
## Data storage
This document describes data storage systems used for this platform - [[Data and ML platform project - Data storage]]
## Airflow setup
Those documents describe how do we setup Airflow:
- [[Data and ML platform project - Airflow setup (prod, AKS)]]
- [[Data and ML platform project - Airflow setup (dev, kind)]]
## Data transformation setup
Below sections describe how to set up tools used for data transformation:
- Spark Thrift Server with Iceberg
- dbt
- Hive Metastore (optional, not used currently)
### Spark Thrift Server and Iceberg
Those documents explain how do we set up Spark Thrift Server and Iceberg:
- [[Data and ML platform project - Spark Thrift Server setup]]
- [[Data and ML platform project - Spark Thrift Server setup - Details]]
### dbt
This document explains how we set up dbt - [[Data and ML platform project - dbt setup]]
### Hive Metastore
This document explains how do we set up Hive Metastore - [[Data and ML platform project - Hive Metastore setup]]

Using Hive Metastore is optional, we don't use it currently but the code is prepared and it worked.
#### Hive vs Iceberg
We can could use:
- Only Hive Metastore
- Both Hive Metastore and Iceberg together

Hive can be used like Iceberg to manage metadata allowing Spark to execute SQL queries.

More info about comparison between Hive and Iceberg can be found here - [[Iceberg vs Hive]].
## MLflow setup
We use MLflow for ML model creation, monitoring and retraining.

More details about setting it up can be found here - [[Data and ML platform project - MLflow setup]].
## Spark Operator
This document explains how to set up Spark Operator - [[Data and ML platform project - Spark Operator setup]]
## Prometheus
This document explains how to set up Prometheus - [[Data and ML platform project - Prometheus setup]]
# Data and ML workflows
Below sections and documents describe how we can use this platform to create data and ML workflows.

In this project, we created one example workflow (more info about it here - [[Data and ML platform project - Example workflow|link]]). 

Next subsections describe what workflows we can create using this platform. It doesn't mean that all of that was implemented in the example workflow.
## Platform workflow example
An example workflow created on this platform for data processing and developing ML models:
- [[Data and ML platform project - Example workflow]]
## Code development & testing scripts
This document explains how we can develop code on a local computer and run it on Kubernetes to test it - [[Data and ML platform project - Code development & testing scripts]]
## Common code
In the `apps/common` folder we have a common code used by all other applications.
## Workflow orchestration with Airflow
Document below describes how workflow orchestration with Airflow looks like on this platform:
- [[Data and ML platform project - Airflow - How to build workflows]]
- [[Data and ML platform project - Workflows orchestrated by Airflow]]
	- [[Data and ML platform project - dbt with Airflow]]
	- [[Data and ML platform project - Making and saving predictions - Airflow orchestration]]
	- [[Data and ML platform project - Automatic update of ML models based on their performance]]
## Data transformation
Documents about data transformation:
- [[Data and ML platform project - Data transformation - Code and practices followed]]
	- [[Data and ML platform project - dbt folder structure]]
- [[Data and ML platform project - Data transformation workflow (dev, kind)]]
## Data ingestion
This document describes how we can perform data ingestion - [[Data and ML platform project - Data ingestion]]
## MLOps with MLflow
MLOps consists of:
- ML model training
- Performance monitoring
- Updating the model used in production with a new one when performance drops

More info about this workflow using MLflow on this platform can be found in documents below:
- [[Data and ML platform project - MLOps with MLflow]]
	- [[Data and ML platform project - Training, evaluating and saving ML models with MLflow]]
	- [[Data and ML platform project - Making and saving predictions]]
	- [[Data and ML platform project - ML model performance monitoring]]
	- [[Data and ML platform project - Automatic update of ML models based on their performance]]
## Monitoring
This document describes what we can monitor and how:
- [[Data and ML platform project - Monitoring]]
# Code
- MLflow projects - [[Data and ML platform project - MLflow projects code|link]] 
# Optional improvements for later
[[Data and ML platform project - Improvements for later]]
# Reference docs for the tools used
Official docs which describes tools used in this project are listed here - [[Data and ML platform project - Official docs for the tools used]]
# To do next
Notes about what to do next - [[Data and ML platform project - To do]] 
# Questions
- Is the `as_of_date` a tag assigned to a table by dbt to know when it was created?
- 