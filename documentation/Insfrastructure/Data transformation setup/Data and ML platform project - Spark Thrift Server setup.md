Tags: [[_My_projects]]
#MyProjects 

# Introduction
Clients (like dbt) can connect to the Spark Thrift Server ([[Spark Thrift Server - How clients connect|link]]) and send SQL queries to execute using JDBC or ODBC drivers which uses Thrift protocol.

Thrift Server uses Iceberg to retrieve necessary metadata to execute SQL queries.

Optionally, Thrift Server could use also Hive Metastore but it is not currently implemented (but code is prepared). More info about it can be found here - [[Data and ML platform project - Hive Metastore setup]].
# Why to use Spark Thrift Server
For data transformation we use dbt and Spark. It is better to use Thrift Server rather than Spark Operator because with the Thrift Server we have a persistent Spark session while Spark Operator creates a new session for every dbt run.

Why it is better to have a persistent session is described here - [[dbt with Spark]].
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
# Datawarehouse
For data storage we use Azure Storage Account ADLS Gen2.

It is specified in the `spark-defaults.conf` file as the `spark.sql.catalog.iceberg_catalog.warehouse` config.
## Connecting from clients
Now clients can connect to the Thrift Server using the JDBC URL:
```bash
jdbc:hive2://spark-thrift.spark.svc.cluster.local:10000/default
```
# Slow performance
If queries are slow, that might be caused by executors being created slowly. We can fix that with:
```
spark.dynamicAllocation.enabled=true
spark.dynamicAllocation.initialExecutors=2
```
# Problems
## Spark with Hive - using local data storage
There is a problem when:
- We use Spark with Hive (what we don't do currently, we use only Iceberg, but code for Hive is prepared so we could use it)
- We want to use localhost filesystem as a storage for Spark data, i.e. when the `spark.sql.warehouse.dir` config points to a folder in a local filesystem
- That folder is a mounted volume which stores data on the localhost using the `hostPath` parameter.

When trying to create a new database `dwh_fact` and table in it, we get an error:
```
Cannot create staging directory  'file:/shared/warehouse/dwh_fact.db/model/.hive-staging_hive_2026-02-20_09-46-34_493_8165871989128179421-1
```
where `spark.sql.warehouse.dir=/shared/warehouse` is the mounted volume.

Issue might be related to file permissions, even though we tried to change umask:
- `spark.sql.warehouse.dir.filePermissionMask=0777` in the Spark config
- `hive.scratchdir.permission=0777` in the Hive config
which causes that every new folder created by Spark and Hive has read/write permissions for everyone (`dwh_fact.db` is such a folder created by Hive).

So Spark should be able to write to `/shared/warehouse/dwh_fact.db` but for some reason we still get this error.
### PV
To use local storage, we need to use the same PV (from the `common` helm chart) for data warehouse mounted into the same path into both pods running the Hive Metastore and Spark Thrift Server.

Path where this PV is mounted needs to be specified in:
- The `spark.sql.warehouse.dir` config in the Spark's pod, in the `hive-site.xml` file
- The `hive.metastore.warehouse.dir` config in the Hive's pod, in the `hive-site.xml` file
### Solution
As a solution we use cloud object storage instead of a local filesystem to avoid issues with file permissions.