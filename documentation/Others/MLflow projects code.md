Tags: [[_My_projects]]
#MyProjects 

# Introduction
In the repository we have folders:
- `apps/common` - Common functions to be used by other MLflow projects:
	- `mlflow` folder - Set of classes with useful functions for working with MLflow
	- `postgresql.py` - Class with functions for performing operations in PostgreSQL which is used as MLflow metadata db. It can be used for example to modify or delete experiments and runs metadata.
- `apps/mlflow_projects/linear_regression_revenue` - MLflow project for building and evaluating a linear regression model for predicting a revenue:
	- `evaluate_all.py` - Script for evaluating all the models from the experiment
	- `evaluate_latest.py` - Script for evaluating the latest model from the experiment
	- `train.py` - Script for training the model
	- `run_script.bash` - Commands to run a MLflow project with different parameters and entrypoints
	- `promote_model.py` - Find the model with the best evaluation metrics and register it (so it can be then easily loaded and used in production data pipelines)
	- `delete_exp_run.py` - Delete an experiment or run