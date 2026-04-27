Tags: [[_My_projects]]
#MyProjects 

# Introduction
This document describes how we make predictions using ML models and save those predictions in the Iceberg catalog.
# A separate table for saving predictions
We run Python scripts orchestrated by Airflow which makes predictions using ML models and save them in a separate table that can be joined with other table which those predictions refer to.

For example one dimension table about clients can have columns:
```
clientID | country | industry
```
 and predictions will be saved in a separate table with columns:
```
clientID | predictedRevenue12m | timestamp | modelID
```
with a predicted revenue for the next 12 months.

The `timestamp` and `modelID` columns indicates which model made the prediction and when.
# Tools used
We use:
- MLflow - To load a model from a MLflow registry using model name and version, and to make predictions with it
- PyHive - To load data from the Iceberg catalog, used to make predictions
- Spark - To save predictions in an Iceberg table
## Improvements
As an improvement, we can use PyIceberg to load and save data in the Iceberg catalog. Docker image which we use will be then much smaller (Spark takes a lot of disk space) and we wouldn't need to mount Spark config files.
# Orchestration with Airflow
We have an Airflow DAG which makes predictions and saves them. More info about it can be found here - [[Data and ML platform project - Making and saving predictions - Airflow orchestration]].
# Preparing data for predictions with dbt
To prepare data for making predictions, we use dbt to build tables:
- Tables representing data from external sources (in the `source1`  and `source2` schemas)
- Other tables by performing transformations on external sources tables

More info about it is here - [[Data and ML platform project - Data transformation workflow (dev, kind)]].
# Scripts for making and saving predictions
For making and saving predictions, we can use two scripts:
- `/apps/airflow/dags/make_predictions/make_predictions_spark_operator.py` - to be run with Spark Operator
- `/apps/airflow/dags/make_predictions/make_predictions.py` - to be run without Spark Operator, using Python

Currently, in the DAG, we use Spark Operator.

Both scripts:
- Loads data from the Iceberg catalog by connecting to the Spark Thrift Server
- Loads a model from MLflow registry
- Makes predictions with it
- Saves predictions using Spark in the Iceberg catalog (not using the Thrift Server but it starts a new Spark driver)
# Running scripts for making and saving predictions
We can run scripts for making and saving predictions using:
- Spark Operator - Install a Helm chart which runs the script using Spark Operator
- Python - Run a dev pod and run manually a script inside of it
- Airflow - As described in the previous section 'Orchestration with Airflow'

More info about it is in the sections below.
## Spark Operator
In order to run the `/apps/airflow/dags/make_predictions/make_predictions_spark_operator.py` script using Spark Operator, we need to perform the steps below (we can perform them from the Docker image for interacting with Kubernetes - [[Data and ML platform project - Docker image for interacting with AKS|link]]):
- Install Spark Operator (as described here - [[Data and ML platform project - Spark Operator setup|link]])
- Install the Helm chart:
```bash
# Run this command from the helm_charts/spark_operator folder
helm -n spark install predict . &
```

This will create `SparkApplication` resource, Spark Operator will notice that and create Spark driver and executor pods, and run the Spark app `make_predictions_spark_operator.py`.
### Checking logs
Once we install the chart, we can check logs from the execution of the Spark script we run by checking logs of the created Spark driver pod:
```bash
kubectl -n spark logs pyspark-app-driver
```
where `pyspark-app` is name of the created `SparkApplication` resource specified in its manifest.
## Python
In order to run the `/apps/airflow/dags/make_predictions/make_predictions.py` script using Python, we can:
- Create a development pod using the `helm_charts/development_pods/mlflow_spark` Helm chart
- Attach VS Code to the created pod or use `exec -it` to get access to pod's shell
- Run the `python3 make_predictions.py` command

More about development pods and attaching VS Code can be found here - [[Data and ML platform project - Code development & testing scripts]]
# Code details
More info about code details can be found here - [[Data and ML platform project - Making and saving predictions - Code details]]