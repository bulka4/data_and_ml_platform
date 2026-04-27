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