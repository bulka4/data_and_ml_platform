Tags: [[_My_projects]]
#MyProjects 

# dbt tags
We use dbt tags to group models based on different criteria:
- `source1` and `source2` tags
	- Tables simulating data from external sources and other tables built using them
- `ml_metrics` tag - Tables with metrics about ML models performance

This is needed because:
- At first we build tables using dbt and data from sources `source1` and `source2`
- Then we use this data to train ML models, make predictions and save them in tables in the Iceberg catalog using Python
- Then we build tables with metrics about ML models performance using dbt (so we need for that predictions)
## Data source group
Models have tags indicating from which source they use data.

For each data source, models which use its data can be built together in a single run, right after data from that source has been ingested. 

Both data ingestion and running dbt models using this data can be done in a single Airflow DAG.
# Simulating data from external sources
In the `dbt/workspace/models/source` folder we have folders with models which simulates data from external sources. Each folder corresponds to a single data source.
# Different data refreshing times
Tables can have different refresh time, some of them can be updated daily while others can be updated weekly or monthly.

We can update all the tables with the same refresh time by using tags (we run a single dbt run command and it builds all the tables with a specific tag which corresponds to a specific refresh time).
# Tables created
We use dbt to prepare data in schemas:
- `source1` and `source2` - Fake external data
- `dwh_dim`, `dwh_fact` - Transformed data using data from sources `source1` and `source2`
- `dwh_ml_metrics` - Tables with metrics about ML models performance (more info here [[Data and ML platform project - ML model performance monitoring|link]])

Some tables, like `dwh_fact.clients_total_revenue_predictions` with predictions (more info here [[Data and ML platform project - Making and saving predictions|link]]) are created outside of dbt, by Python scripts.
# dbt folder structure
dbt folder structure is described here - [[Data and ML platform project - dbt folder structure]]
# dbt with Airflow
Notes about using dbt with Airflow are here - [[Data and ML platform project - dbt with Airflow]].