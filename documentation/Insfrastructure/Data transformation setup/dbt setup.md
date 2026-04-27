Tags: [[_My_projects]]
#MyProjects 

# Introduction
dbt uses the Thrift protocol to connect to the Spark Thrift Server ([[Data and ML platform project - Spark Thrift Server setup|link]]) and send SQL queries to execute.
# Code
Code of the dbt project is saved in the `apps/dbt` folder. In order to run it, we can:
- Create a development pod and run that code there as described here - [[Data and ML platform project - Data transformation workflow (dev, kind)|link]], in the "Preparing a dev pod for running dbt commands" section
- Run it as a Kubernetes job created by Airflow - [[Data and ML platform project - dbt with Airflow|link]]

More information about the code can be found here - [[Data and ML platform project - Data transformation - Code and practices followed|link]].
## Schema where tables will be saved
Tables will be saved in the schema called `{project_schema}_{profiles_schema}`, where:
- `project_schema` - schema name specified in `dbt_project.yml` file
- `profiles_schema` - schema name specified in `profiles.yml` file
## Iceberg catalog
dbt saves tables in an Iceberg catalog configured in Spark.

Looks like in dbt we can't specify the catalog where to save tables, so we need to set up the Iceberg catalog as a default one in the Spark Thrift Server to which dbt connects.

More info in the 'Spark Thrift Server > Iceberg catalog' section.
## Making code available in pods
To make code to execute available in pods we run (which run dbt), we use an init container which pulls code from a repo.

More info about Making code available in pods can be found here - [[Data and ML platform project - Making code available in pods]].
## dbt with Airflow
Notes about using dbt with Airflow are here - [[Data and ML platform project - dbt with Airflow]].