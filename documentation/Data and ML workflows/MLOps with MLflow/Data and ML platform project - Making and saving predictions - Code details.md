Tags: [[_My_projects]]
#MyProjects 

# Spark Operator - Dynamic configurations
When using Spark Operator, there is a problem with providing dynamic values (for example from secrets) into the `spark-defaults.conf` file. or in the SparkApplication CRD as described here - [[SparkApplication CRD - Dynamic configs (using values from secrets)|link]].

That's why we provide values for configuration in the Python script with our Spark app (it is done by the `prepare_iceberg_configs` function from the `apps/common/spark.py` script).