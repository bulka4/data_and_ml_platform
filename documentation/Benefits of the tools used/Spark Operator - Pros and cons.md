Tags: [[__Data_Engineering]], [[__Distributed_computing]]
#DataEngineering #DistributedComputing 

# Pros
- Less manual Spark configuration (Spark Operator automatically handles a part of that)
- Observability
	- All the logs well structured in `SparkAplication` resource (no need to check multiple Pods)
	- Job status easy to see in `SparkApplication`
	- Easy integration with Prometheus, Grafana, Spark History Server
- Resource cleanup
	- Automatically cleans up driver and executor pods after executing a job (or after deleting a single `SparkApplication` resource)
	- We only need to clean `SparkApplication` resource
- Job templating and parametrization
	- Specifying job parameters using YAML file
	- Easier to work with compared to CLI commands
- Retry support
	- It can retry a single Executor Pod.
# Cons
- Difficult to set up.