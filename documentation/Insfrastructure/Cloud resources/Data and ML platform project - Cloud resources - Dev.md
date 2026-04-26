Tags: [[_My_projects]]
#MyProjects 

# Introduction
This document explains infrastructure setup for development on kind for the Data and ML platform project.

Terraform prepares:
- Azure Data Lake
- Service Principal
# Service Principal
Terraform creates a Service Principal with permissions for saving and reading data from Azure Storage Account.

It is used by many parts of the platform:
- Airflow to save logs in Azure Storage Account
- Spark to read and save data in Azure Storage Account
# Storage Account
We use Azure Storage Account (object storage) for storing:
- DWH (data warehouse) data 
	- Used for analytics and ML
	- We use Delta Lake storage framework for that data
- Airflow logs
- MLflow artifacts

We have the following Storage Accounts and containers:
- dwhbulka Storage Account
	- DWH container
		- DWH (data warehouse) data
	- mlflow container
		- MLflow artifacts
- systemfilesbulka Storage Account
	- airflow-logs container
		- Airflow logs