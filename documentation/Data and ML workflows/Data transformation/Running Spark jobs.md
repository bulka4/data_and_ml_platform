Tags: [[_My_projects]]
#MyProjects 

# Introduction
Below sections describe how to run Spark jobs
# SQL queries
If we want to run SQL code, we do this via Spark Thrift sever and:
- dbt - as explained here - [[Data and ML platform project - dbt setup|link]], [[Data and ML platform project - Spark Thrift Server setup|link]] 
- Beeline - as explained here - [[Data and ML platform project - Data Transformation - Running SQL queries using Thrift server and Beeline|link]] 
# PySpark apps
If we want to run a PySpark app, we can run it:
- As a Kubernetes job
- Or using Spark Operator

For example, we do this when making and saving ML predictions as explained here - [[Data and ML platform project - Making and saving predictions|link]] in the "Running scripts for making and saving predictions" section