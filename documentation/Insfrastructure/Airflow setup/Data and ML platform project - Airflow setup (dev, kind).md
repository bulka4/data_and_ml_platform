Tags: [[_My_projects]]
#MyProjects 

# Accessing Airflow webserver
We can access Airflow UI at the `localhost:8080` URL.

We use a `nodePort` type of a Kubernetes service for the webserver to enable accessing this URL from the host.

This service is specified in `helm_charts/airflow/values.yaml` file and we also map the port used in the `nodePort` to the host port in the `kind-config.yaml` file (so we can access this service from our host, not from a kind node container).

In `helm_charts/airflow/values.yaml` we specify the `NodePort` service to be used:
```yaml
webserver:
	service:
		type: NodePort
		ports:
			- port: 80          # service port (used inside the cluster)
			  targetPort: 8080  # container port
			  nodePort: 30080   # node port
```

and we map the `nodePort` to the port on the host in the kind-config file:
```yaml
nodes:
	- role: control-plane
		- containerPort: 30080
		  hostPort: 8080
		  protocol: TCP
```

Then, the traffic will go like this:
- host port (port on the host specified in the `kind-config.yaml`) ->
- container port / node port (port in the kind node container, specified in the `kind-config.yaml` as `containerPort` and in the service as `nodePort`) ->
- target port (port in the container running in the kind cluster, specified in the service)
# Mounting DAGs code into Airflow pods
To make DAGs code available for Airflow, we need to mount a folder from the local host. There are two approaches:
- Mount the `apps` folder to have local files available
- Mount the `git_code` folder and use git-sync to pull code from a repo into that folder (to test git-sync).

The `dagsPvc.hostPath` parameter in the `values.yaml` specifies which folder we want to mount.

Depending on what option we choose, we need to also provide a proper `subPath` parameter:
- When `hostPath` = `apps`, then `subPath` = `airflow/dags`
- When `hostPath` = `git_code`, then `subPath` = `apps/airflow/dags`
## Git-sync
We can use git-sync to pull code from a git repo and make it available in pods running Airflow components (scheduler etc).

It is not necessary on kind as we can mount from the localhost but once we want to run Airflow on a Kubernetes cluster in cloud, this is a good option.

Git-sync is deployed separately using its own Helm chart (`helm_charts/git_sync`). It will save code on the host in the `git_code` folder which we can then mount into Airflow pods.

More info about it can be found here - [[Data and ML platform project - Making code available in pods]], in the 'git-sync' section.
# Metadata db
We create a PostgreSQL db for Airflow metadata as a separate deployment in the same Helm chart.

We do this so we don't pay for a managed service but for production it is recommended to use a managed service since running a database on Kubernetes is problematic as described here - [[Kubernetes - Running databases]].
# Service account
We create a service account which will be used by Airflow pods for creating new pods where tasks will be executed. 

In `values.yaml` we define that this service account will be used by Airflow components (scheduler etc.).
# dbt with Airflow
Notes about using dbt with Airflow are here - [[Data and ML platform project - dbt with Airflow]].
# Airflow logs
Airflow logs are being saved to Azure Storage Account. This is set up using env vars in `values.yaml` file, like `AIRFLOW__LOGGING__REMOTE_LOGGING`.
# Differences from the prod deployment
This section describes how running Airflow on AKS differs from running it on kind.
## DAGs PV
In prod, as a storage for DAGs PV we use Azure File share.
## Service Account
In prod, Service Account uses a secret for pulling images from ACR.
## Exposing and accessing the Airflow webserver
In prod we use a load balancer service for the webserver so it gets a public IP which we use to access Airflow UI.