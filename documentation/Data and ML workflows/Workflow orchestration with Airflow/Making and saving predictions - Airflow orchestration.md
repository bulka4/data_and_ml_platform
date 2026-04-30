Tags: [[_My_projects]]
#MyProjects 

# Introduction
The `airflow/dags/make_predictions/dag_making_predictions.py` script contains DAG which makes predictions using a ML model from the MLflow registry and saves them in the Iceberg catalog using Spark.

It creates the `make_predictions` DAG visible in Airflow UI which we can run from there.
# Prerequisites
Before we run this DAG we need to make sure that the below prerequisites are satisfied.
- Installed Spark Operator and created service account for it (as described here - [[Data and ML platform project - Spark Operator setup|link]])
# Script to run
On kind, Spark script to run is provided through mounting from the host (more details in the DAG script comments).
# Running from Airflow
We can run the 'make_predictions' DAG from Airflow UI. 

It creates then a `pyspark-app` SparkApplication resource which we need to delete then before the next run (otherwise Airflow will try to create another resource with the same name and fail):
```bash
kubectl -n spark delete sparkapplication pyspark-app
```
## Checking logs
To check logs about executing Spark job we can check logs from the pod running the Spark driver using this command:
```bash
kubectl -n spark logs pyspark-app-driver
```
or we can also check logs in the `SparkApplication` resource:
```shell
kubectl -n spark describe sparkapplication pyspark-app
```

More info about it can be found here - [[Data and ML platform project - Making and saving predictions|link]], in the 'Spark Operator > Checking logs' section.
# Questions
- 