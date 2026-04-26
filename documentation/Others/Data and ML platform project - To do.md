Tags: [[_My_projects]]
#MyProjects 

# To do
- Make additional notes about:
	- Further improvements which could be done
	- How to use this platform in practice (what practices to follow)
	- What are the benefits of the tools used here (done)
- Record videos about how to use this platform
- Additional ML monitoring metrics
	- Monitor additional metrics about ML performance, like data drift
- dbt UI
	- Prepare a Helm chart running dbt UI
	- Use `dbt docs generate` and `dbt docs serve` commands
- Monitoring tools
	- Use Prometheus and / or Grafana for monitoring:
		- Nodes resources utilization
- Jupyter Notebook for code development
- Data ingestion
	- Set up PostgreSQL pod as data source
	- Write Python code for ingesting data into Data Lake
		- Save it as Iceberg table straight away (optional)
	- Run it with Airflow
- In dbt, mark tables ingested from external sources as source tables
- testing source data in dbt
- dbt with Airflow and Cosmos
# Updating a model
In the Airflow DAG for updating the model, when we pick up the best model, check only new metrics (calculated for new data).
# Airflow operators
- Create an Airflow operator for making and saving predictions and use it in the `make_predictions` DAG
	- Draft prepared, need to test it
- Use the Airflow operator I created for running Kubernetes jobs in the dbt DAG
- 