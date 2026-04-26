Tags: [[_My_projects]]
#MyProjects 

# Introduction
For developing code we can create a development pod and connect to it so we can run code inside of it and modify files.
# Development pods
In the `helm_charts/development_pods` folder we have Helm charts which can be used for code development and testing. 

They create pods to which we can connect, edit files in them and run scripts.

Available development pods in the `development_pods` folder are:
- `mlflow_spark` - Contains everything to run MLflow and Spark
- `dbt` - For running dbt projects. More info about using it is in the 'Building tables with dbt' section here - [[Data and ML platform project - Data transformation workflow (dev, kind)|link]].
- `airflow` - For testing Airflow code (e.g. custom operators from `airflow/dags/common` folder, creating pods using Kubernetes Python client)
# Connecting to pods
We can connect to a created development pod so we can edit files in them and run scripts. To do this, there are two approaches described in sections below.
## Interactive shell
We can start an interactive shell session using:
```shell
kubectl -n <namespace> exec -it <pod-name> -- /bin/bash
```
That gives us access to the shell session inside the pod so we can run shell commands and see their outputs.
## Attaching VS Code to a pod
We can attach VS Code to the created development pods and from it we can edit pod's files and run shell commands.

How to use VS Code Kubernetes extension, to attach VS Code to a pod as described here - [[Data and ML platform project - VS Code Kubernetes extension setup for code development]].