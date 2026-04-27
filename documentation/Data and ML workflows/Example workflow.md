Tags: [[_kind]] [[__Cloud]], [[__DevOps]], [[__Distributed_computing]], [[__Infrastructure_Engineering]]
#kind #Cloud #DevOps #DistributedComputing #DataEngineering 


# Prepare fake external data and transform it
Using dbt, build:
- Tables representing data from external sources
- Other tables by performing transformations on those external sources tables
as described in the 'Build tables using data from source1 and source2 sources' section here - [[Data and ML platform project - Data transformation workflow (dev, kind)|link]].
# Train and save ML models
Train ML model and save it the registry using prepared data as described here - [[Data and ML platform project - Training, evaluating and saving ML models with MLflow|link]], in the section about running MLflow projects.
# Make and save predictions
Run the Airflow DAG to make and save predictions as described here - [[Data and ML platform project - Making and saving predictions - Airflow orchestration|link]].
# Calculate metrics about model performance
Using dbt, build tables for ML model performance metrics as described here - [[Data and ML platform project - Data transformation workflow (dev, kind)|link]], in the 'Build tables with ML metrics' section
# Update ML models used in production automatically
Run Airflow DAG for automatic ML model update as described here - [[Data and ML platform project - Automatic update of ML models based on their performance|link]].