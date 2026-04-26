Tags: [[_My_projects]]
#MyProjects 

# Running Spark Thrift Server
To run Spark Thrift Server we need to install the Helm chart:
```bash
# Run this command in the helm_charts/spark_thrift_server folder
helm -n spark install spark . &
```
## Running SQL queries with Beeline CLI tool
To query data we created in a Spark catalog, we can:
- Connect to the pod running Spark Thrift server:
  ```bash
  kubectl -n spark exec -it <pod-name> -- /bin/bash
  ```
  - Connect to Spark using Beeline:
    ```bash
    /opt/spark/bin/beeline -u jdbc:hive2://localhost:10000
    ```
- Then, we can run SQL queries
# Preparing a dev pod for running dbt commands
To build tables we need to run a dbt project. We can do this in a dev pod ([[Data and ML platform project - Code development & testing scripts|link]]) created by a prepared Helm chart.
## dbt files to run
dbt will use code from the git repo, from the path `apps/dbt` (it will be pulled when starting the pod), so we need to have that code uploaded to the repo.

For local testing, we can change this to use code from the localhost. We would need to use a PV with a `hostPath`.

Using cloning from a git repo would be useful if we would like to run it on a Kubernetes cluster in cloud.
## Prepare a dev pod for running dbt commands in it
- We need to have Spark Thrift Server running (as described earlier)
- Install the chart creating a dev pod for running dbt code:
```bash
# Run this command in the helm_charts/development_pods/dbt folder
helm -n spark install dbt . &
```
- Get access to a bash session in the created pod:
```bash
kubectl -n dbt exec -it dbt -- /bin/bash
```
- Now we can run dbt commands in the pod.

That should create tables visible in Azure Data Lake. 

dbt connects to the Spark Thrift server in order to build those tables and they are created in the Iceberg catalog.
# Build tables using data from source1 and source2 sources
To build:
- Tables representing data from external sources (in the `source1`  and `source2` schemas)
- Other tables by performing transformations on external sources tables

We can:
- Prepare a dev pod where we can run dbt commands (like described in the previous section "Preparing a dev pod for running dbt commands")
- Run this command in that pod (build only tables with tags `source1` or `source2`):
```bash
dbt run -s tag:source1 tag:source2
```

This data can be then used to train ML models as described here - [[Data and ML platform project - Training, evaluating and saving ML models with MLflow|link]].
# Build tables with ML metrics
Metrics are saved in the `dwh_ml_metrics` schema.

Before we build tables with metrics about ML predictions, we need to have the `dwh_fact.clients_total_revenue_predictions` table prepared with predictions (more info here - [[Data and ML platform project - Making and saving predictions|link]])

Once we have the table with predictions, we can build tables with ML metrics (with the `ml_metrics` tag). In order to do this:
- Prepare a dev pod where we can run dbt commands (like described in the previous section "Preparing a dev pod for running dbt commands")
- Run this command in the prepared pod:
```bash
dbt run -s tag:ml_metrics
```

More info about ML metrics is here - [[Data and ML platform project - ML model performance monitoring|link]].
# Airflow DAG
- Go to the Airflow UI at `localhost:8080`
- Trigger the dbt DAG from the Airflow UI
