Tags: [[_My_projects]]
#MyProjects 

# Introduction
For now we don't perform data ingestion on this platform but everything is prepared to do so.

Data ingestion can be performed using Python which can run in its own pod on Kubernetes created by Airflow.

We can use for that the custom Airflow operator from the `airflow/dags/common/KubernetesJobOperator.py` script which runs a Kubernetes job.
# Useful repository
This repository - [airflow_data_lake_ingestion](https://github.com/bulka4/airflow_data_lake_ingestion/tree/main), contains code which can be useful for creating data ingestion pipelines on this platform.

Code in this repository performs data ingestion using Python from a SQL database into Delta Lake tables in Azure Data Lake Gen2.

On this platform we use Iceberg instead of Delta Lake so we would need to change the part of the code related to that, but there are still some useful functions, for example:
- Interacting with Azure Data Lake - creating containers, folders, files, setting up permissions for accessing it
- Incremental load logic
- Connecting to MySQL
# Checking row counts
During every data ingestion, we can check how many new rows we are ingesting. This can be used to detect issues, if one day we have significantly less or no new records, that might indicate some issue.