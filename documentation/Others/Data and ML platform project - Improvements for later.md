Tags: [[_My_projects]]
#MyProjects 

# MLflow
## Data reproducibility for MLflow projects
Ensure that when we run a MLflow project, we always use the same data (for training or evaluating).

To do that, use:
- Data versioning - select data from a specific Iceberg version
- For dimension tables that change over time (like user status), use dbt snapshots
	- Select records where `valid_from` < `date_of_training` < `valid_to`
## Monitoring
Additional ideas for monitoring - [[Data and ML platform project - Monitoring - Ideas]].
## Jupyter Notebook
Set up a server running a Jupyter Notebook which users can use over a browser to use Spark.
## Training with DeepSpeed
Training models using DeepSpeed and Kubeflow TrainingRuntime CRD like described here - [[DeepSpeed cluster project]].
## RAG system
RAG system with access to dbt data dictionary. Use the RAG system I already created and modify it - [[RAG app project]].
## PyIceberg
Use PyIceberg for writing data into the Iceberg catalog instead of Spark. That can be used for example when:
- Ingesting data from external sources
- Making prediction with a ML model and saving them in an Iceberg table

Benefit of that is that PyIceberg image would be much smaller than the Spark one and we don't need to mount Spark configuration files.