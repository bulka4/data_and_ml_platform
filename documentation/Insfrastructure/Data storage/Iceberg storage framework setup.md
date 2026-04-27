Tags: [[_My_projects]]
#MyProjects 

# Introduction
Iceberg is used by Spark when reading and saving data. We configure it when configuring Spark, in Spark configuration.

We do this for example when setting up:
- Thrift server (more info here - [[Data and ML platform project - Spark Thrift Server setup|link]]) 
- Or when running Spark jobs for saving predictions (more info here - [[Data and ML platform project - Making and saving predictions|link]], in the "Running scripts for making and saving predictions" section)
# Iceberg catalog
In the `spark-defaults.conf` file, we:
- Create an Iceberg catalog called `iceberg_catalog`
- Make it a default catalog by setting up `spark.sql.defaultCatalog=iceberg_catalog`

This causes that:
- Every table created without specifying a catalog, will automatically be placed in this catalog
- Every table created in the Iceberg catalog is an Iceberg table

This is used by dbt, because it looks like in dbt we can't specify in which catalog to save data, it only uses the default one.

This also helps when saving data using the Python `pyhive` library - saved data is automatically an iceberg table.

If Iceberg catalog is not a default catalog in Spark, then dbt saves data in the `spark_catalog` catalog.
# Iceberg config
We specify configs for Iceberg in the `spark-defaults.conf` file.
# Iceberg default schema init
Before we start using Spark Thrift server (for example when we want to execute a SQL query using Beeline or dbt) with Iceberg catalog set up as a default one, we need to have already created the `default` schema in this catalog. Otherwise, we get an error that this schema doesn't exist.

That's why we run the `init_iceberg_schema.py` python script (baked in the Spark image) in an init container in the Spark's pod which creates that schema. That script is able to run a SQL query for creating a schema because it creates a Spark session without Iceberg catalog set up as a default one.