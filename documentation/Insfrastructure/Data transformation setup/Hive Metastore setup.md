Tags: [[_My_projects]]
#MyProjects 

# Connecting from clients
Clients can connect to the Hive Metastore using URL:
```bash
thrift://spark-thrift-server-hive-metastore:9083
```
## Hive CLI
- In order to use Hive CLI:
	- From the pod running Hive Metastore:
		- Use the `hive --hiveconf hive.metastore.uris=thrift://localhost:9083` command
	- From other pods:
		- Use the `hive --hiveconf hive.metastore.uris=thrift://{{ .Release.Name }}-hive-metastore:9083` command
# PostgreSQL metadata db
Helm chart which deploys Hive Metastore, also deploys PostgreSQL which will be used as metadata db.
# Hadoop version
We use Hadoop 3.3.6 which has azure jars in the `/opt/hadoop/share/hadoop/tools/lib/` folder. Those jars are used to connect to Azure Storage Account ADLS Gen2.
# Datawarehouse
For data storage (specified in the `hive-site.xml` as the `hive.metastore.warehouse.dir` config) we use Azure Storage Account ADLS Gen2.
# Helm chart
We prepared a Helm chart deploying Hive Metastore as an optional to use. It can be installed using a Helm chart:
```bash
# Execute below commands from the helm_charts/hive_metastore folder
helm -n spark install hive . &
```

More info about setting up Hive can be found here - [[Data and ML platform project - Hive Metastore setup]].
# Spark configs for using Hive
In order to use Hive Metastore we need to use different Spark config files which are located in the `helm_charts/spark_thrift_server/spark_configs` folder (they are not being used currently):
- `hive-conf.yaml` - Config files to use only Hive
- `hive-iceberg-conf.yaml` - Config files to use both Hive and Iceberg

We would need to use them instead of the currently used `spark_thrift_server/templates/configuration-configmap.yaml` file.
# Problems
## Problems with the official Hive Docker image
When using official Docker images `apache/hive` we were getting problems like:
- Old Hadoop version 3.1.0 had Azure jars which don't support connecting to Azure Storage Account (there was no `SecureAzureBlobFileSystem` class in the `hadoop-azure-xxx.jar`)
- There were errors like:
	```bash
	There is no available StoreManager of type "jdbc". Make sure that you have put the relevant DataNucleus store plugin in your CLASSPATH
	```
	when starting Hive Metastore, even though all the datanucleus jars were included in the `$HIVE_HOME/lib` folder which is included in the Hive's classpath. In the same folder we had Postgres driver and it was used (Hive managed to initialize schema (metadata db)).

That's why we have built our own image from scratch.