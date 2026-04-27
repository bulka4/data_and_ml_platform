Tags: [[_My_projects]]
#MyProjects 

# Introduction
Official docs which describes tools used in this project:
- Spark Operator:
	- Code repo for the release we use - [link](https://github.com/kubeflow/spark-operator/tree/release-2.1) 
	- Code related to the `controller start` command which is used to start Spark Operator controller - [link](https://github.com/kubeflow/spark-operator/blob/release-2.1/cmd/operator/controller/start.go) 
	- Source code of the Helm chart `spark-operator` which we use to install Spark Operator - [link](https://github.com/kubeflow/spark-operator/blob/release-2.1/charts/spark-operator-chart/templates/controller/deployment.yaml) 
		- We can find here for example what parameters we can pass using the `--set param=value` flag when installing Spark Operator Helm chart using `helm install`
		  
		  Those parameters are marked as `{{ .Values.param_name }}` in the Helm chart.
	- 