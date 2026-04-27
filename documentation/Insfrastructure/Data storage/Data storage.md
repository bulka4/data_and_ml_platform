Tags: [[_My_projects]]
#MyProjects 

# Object data storage
We use Azure Data Lake Gen2 (object storage) prepared by Terraform ([[Data and ML platform project - Cloud resources - Prod|link]]) for storing:
- DWH (data warehouse) data 
	- Used for analytics and ML
	- We use Iceberg storage framework for that data
- Airflow logs
- MLflow artifacts
## Iceberg
For storing tables in Data Lake, we use Iceberg storage framework. More information about how it is being configured can be found here - [[Data and ML platform project - Iceberg storage framework setup]].
# SQL databases
Additionally, we use:
- PostgreSQL for Hive Metastore metadata (deployed on Kubernetes)
- PostgreSQL for Airflow metadata (deployed on Kubernetes)
- MySQL as a MLflow backend store (deployed on Kubernetes)