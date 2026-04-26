Tags: [[_My_projects]]
#MyProjects 

# Data preparation in dbt
To prepare a dataset for training a model, we use dbt to build tables:
- In the `source1`  and `source2` schemas (fake external sources)
- Other tables which are a result of transformations of data from those sources (used for training)

More info here - [[Data and ML platform project - Data transformation workflow (dev, kind)|link]] in the 'Build tables using data from source1 and source2 sources' section.
## Data reproducibility
We make sure, that when we prepare a dataset for training a model within a MLflow project, we always get exactly the same dataset, no matter when we run that project.

To ensure that, we can:
- Select data within a specific time frame
- Use Iceberg time travel and tags to select a snapshot of a dataset used for training
- For dimension tables that change over time (like user status), use dbt snapshots
	- Select records where `valid_from` < `date_of_training` < `valid_to`
- Use MLflow to save logs about:
	- SQL query used to generate the data, which includes:
		- Table names
		- Iceberg version or timestamp of tables
	- Commit hash of the code used (in case someone changes the code):
		- dbt code
		- Infrastructure configuration (K8s YAML manifests used):
			- Spark
			- dbt
	- hyperparameters
# MLflow tags
Tags we use in MLflow projects:
- `created_model_uri` - URI of the model created in the given run
- `evaluated_model_uri` - URI of the model only evaluated in the given run (but created in another run)
- `evaluated_ model_source_run_id` - Run ID where the model which has been evaluated, was created
# MLflow project parameters
When running MLflow projects, we provide parameters such as:
- Start and end date - A date range for which to select data used for training or evaluation
- Model hyperparameters - To use for training
# MLflow workflow
## Experiments
- Each experiment corresponds to a specific goal, like predicting a revenue.
- Each run in an experiment is either building a model or evaluating it
- There can be different kinds of models taking different inputs in a single experiment
## MLflow projects
- Each MLflow project contains code for building and evaluating one specific kind of model, taking specific features as an input.
- Models logged by each project needs to contain information about from which project they come from.
	- So we can evaluate models only from a single project.
- Evaluating script evaluates models only from the project where that script belongs to. 
	- Models from different projects will require different evaluation techniques as they can take different features as an input.
- Evaluating script can evaluate:
	- All the models after a specified date
	- All models in an experiment
	- The latest model
	- Models with specific parameters, tags, names
## Runs
- Evaluating runs:
	- Each run for evaluating a model, evaluates only one model and logs:
		- metrics
		- URI of the evaluated model
		- ID of the run where the evaluated model has been built
	- One script (project entrypoint) can create multiple runs, each one evaluating a different model
## Promoting a model (saving in a registry)
To promote a model, i.e. save it in a MLflow registry, we use the `promote_model.py` script which finds URI of the model with the best performance.

This script finds the model with the best performance by searching through runs which were:
- Evaluating models
- Saving evaluation metrics and URIs of evaluated models
and picks a URI of the model with the best metrics.
# Running MLflow projects for training, evaluating and saving models
## Create a development pod
We can use development pods to develop and test MLflow code.

We create a dev pod:
```bash
# Run this from the helm_charts/development_pods/mlflow_spark folder
helm -n mlflow install dev-pod . &
```
and connect to it like described here -  [[Data and ML platform project - Code development & testing scripts|link]], in the "Connecting to pods" section, so we can run shell commands and edit files in it by:
- Attaching a VS code
- using `kubectl exec -it` command
### Mounted files
The `apps` folder from the host will be mounted to the created development pod. So we can edit code on the host and then run it from that pod.
## Run MLflow projects
  Use files from the `/root/apps/mlflow_projects/linear_regression_revenue` folder in a dev pod to perform actions described below:
  - Use commands from the `run_script.bash` file:
	  - Run the command for training (we can create multiple models using different parameters `fit_intercept` and `positive`)
	  - Run the command for evaluating all the models
  - Run the `python3 promote_model.py` command to run the Python script which takes the best model (with the best metrics from the evaluation) and saves it in the MLflow registry
  - To delete an experiment / run, use the `delete_exp_run.py` script.