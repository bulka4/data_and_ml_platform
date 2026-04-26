Tags: [[_My_projects]]
#MyProjects 

# Introduction
This document describes how to create workflows in Airflow and what features are available.
# Testing Airflow code
For testing Airflow code, for example custom operators from `airflow/dags/common` folder or creating pods using Kubernetes Python client, we can use the `helm_charts/development_pods/airflow` Helm chart which prepares a development pod ([[Data and ML platform project - Code development & testing scripts|link]])
# Running Kubernetes jobs
We run Airflow tasks as Kubernetes jobs because jobs can restart in case of failure. We create those Airflow tasks such that:
- Task finishes when the job finishes
- Wen job fails, then Airflow task fails as well

We use for that a custom Airflow operator defined in the `airflow/dags/common/KubernetesJobOperator.py` script which uses the Kubernetes Python client.
## Parametrized YAML with Jinja templating
When providing a YAML manifest for Kubernetes job we want to run, we can prepare that YAML using Jinja templating and render it (insert values of variables) using the `Jinja` class from the `airflow/dags/common/jinja.py` script.
## Running Spark jobs using Spark Operator
If we want to run a Spark job using Spark Operator from Airflow, by creating a `SparkApplication` resource, we can use for that the custom Airflow operator from the `airflow/dags/common/SparkApplicationOperator.py` script.

Just like in case of jobs:
- Task finishes when the `SparkApplication` finishes
- Wen `SparkApplication` fails, then Airflow task fails as well
# Airflow conditional tasks
We can use the custom Airflow operator from the `airflow/dags/common/ShouldContinueOperator.py` script to create a conditional task which decides whether or not to progress with next, downstream tasks. 

If it decides not to progress, then downstream tasks are skipped, not marked as failed.

It works like that:
- Run a specified Kubernetes Job 
- Save messages in a JSON format in job pod's termination logs
- Check whether specified message exists in termination logs:
	- If it exists, then continue with downstream tasks
	- Otherwise, skip all the downstream tasks
# Making code available in pods
How to make a code to run available in pods created by Airflow tasks is described here - [[Data and ML platform project - Making code available in pods]].