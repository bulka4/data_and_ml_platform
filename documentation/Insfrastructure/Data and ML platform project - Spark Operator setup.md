Tags: [[_My_projects]]
#MyProjects 

# Introduction
Spark Operator is used for running Spark jobs using `SparkApplication` CRD. 

In the `SparkApplication` CRD we define what Spark script to run and how to prepare environment for Spark driver and executor pods.

When we create a `SparkApplication` CR, then Spark Operator notices that and creates Spark driver pod which then creates executor pods.
# Helm chart
We have the `helm_charts/spark_operator` Helm chart which can be used to either:
- Create both `SparkApplication` and service account
- Create service account only

Whether or not we want to create `SparkApplication` is controlled by the `createSparkApplication` parameter.

Service account is used by the Spark Operator to create a Spark driver pod so we can create only it and create `SparkApplication` later which will use this service account.
# Setup
## Install Spark Operator
In order to install Spark Operator, we can use commands from the `helm_scripts/install_spark_operator.sh` script:
```bash
helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update

helm install spark-operator spark-operator/spark-operator -n spark \
  --set sparkOperatorVersion=v1beta2-2.1.0-3.5.0 \
  --set spark.jobNamespaces={spark} \
  --set webhook.enable=true \
  --set webhook.enableCertManager=false \
  --set webhook.generateSelfSignedCert=true
```
## Create service account for Spark Operator
Spark Operator needs a service account so it can create a Spark driver pod. 

We can create it without creating `SparkApplication` by installing the `helm_charts/spark_operator` Helm chart with the `createSparkApplication=false` parameter:
```shell
# Run this from the helm_charts/spark_operator folder
helm -n spark install spark-operator-sa . \
	--set createSparkApplication=false &
```

We can use it when creating a `SparkApplication` later.