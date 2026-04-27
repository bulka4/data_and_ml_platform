Tags: [[_My_projects]]
#MyProjects 

# Introduction
We deploy Airflow using the official Helm chart. Thanks to that, each Airflow component runs in a separate pod:
- Scheduler
- Webserver
- Workers
- etc.

PostgreSQL is used as a metadata database and is deployed separately in the same chart.

Also, to make DAGs code available for Airflow components, we can:
- Use git-sync (deployed using a separate Helm chart) which pulls code regularly
- Mount files from the host using a PV with a `hostPath`

more info about making code available in pods in general is here - [[Data and ML platform project - Making code available in pods|link]].
# Helm chart
To deploy Airflow on Kubernetes we use the official Helm chart. It is used as a dependency in the `helm_charts/airflow/Chart.yaml` file.
## values.yaml
The `values.yaml` file will be provided for that chart in the `helm_charts/airflow` folder and it will be created by Terraform ([[Data and ML platform project - Preparing files with Terraform|link]]).

It interpolates the `terraform/template_files/helm_charts/values-airflow.yaml` template to create it ((inserts variables values into the template file). 
## Git-sync
We use git-sync to pull code from a repo. That code will be available in pods running Airflow components (scheduler etc) and also in created pods running tasks.

git-sync runs in a separate pod, pulls code from repo and saves it in a persistent volume. Then we can mount that volume to other pods to make the code available.

More details about how git-sync works can be found here - [[Git-sync - Kubernetes deployment]].
### File Share
Persistent volume, mounted into the pod running git-sync, into which pulled code is being saved, stores that code in Azure File Share.

We use File Share because it supports RWX (ReadWriteMany) access mode, so we can use that volume for read/write in many pods running on many nodes.

Kubernetes secret with an access key to the Storage Account with that File Share is used for accessing it.
# Airflow logs
Airflow logs are being saved in Azure Storage Account. We configure that in the `values.yaml` file.
## Service Principal
We create a connection which uses credentials of a Service Principal with permissions to connect to Storage Account (it is configured also in the `values.yaml` file)
# Metadata db
We create a PostgreSQL db for Airflow metadata using Airflow Helm chart.

For production, it is worth considering using a managed Postgres service as running databases on Kubernetes has challenges as described here - [[Kubernetes - Running databases]].
# Service account
We create a service account which will be used by Airflow pods for creating new pods where tasks will be executed. 

In that service account we specify what secret will be used in created pods for authentication when pulling an image.
# Exposing and accessing the Airflow webserver
For exposing the Airflow webserver we use a load balancer Kubernetes service. Its external IP can be used to access Airflow UI in a browser. It is accessible under this URL: 
```
<webserver-service-external-ip>:8080
```

Creation of this service is specified in `helm_charts/airflow/values.yaml` file by setting up the `webserver.service.type=LoadBalancer` parameter.
# To do
## webserver URL env var
In Airflow pods we need to set up as a value of the `AIRFLOW__WEBSERVER__BASE_URL` env var an IP of the load balancer service.

The problem is that both setting up that env var and creating a load balancer service is done when installing the chart so before that we don't know the load balancer's IP.

We can either update webserver URL env var after installation of the Helm chart or create an ingress. Start with the first option (simpler), if it works, then check an ingress option.
### Update after chart installation
Update webserver URL in pods after installation:
```bash
kubectl -n airflow exec -it airflow-webserver -- /bin/bash
AIRFLOW__WEBSERVER__BASE_URL="http://<webserver_service_external_ip"
```
### Create an ingress
I can create ingress in values.yaml:
```yaml
webserver:
  ingress:
    enabled: true
    ingressClassName: nginx   # or azure/application-gateway
    hosts:
      - name: airflow.example.com
        path: /
    tls:
      enabled: true
      secretName: airflow-tls
  config:
    AIRFLOW__WEBSERVER__BASE_URL:
      value: "https://airflow.example.com"
```

or use nginx ingress controller:
```bash
kubectl get pods -n ingress-nginx # check if it already exists
helm install ingress-nginx ingress-nginx/ingress-nginx # install
kubectl get ingress # get address
```
