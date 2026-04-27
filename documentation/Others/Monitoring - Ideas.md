Tags: [[_kind]] [[__Cloud]], [[__DevOps]], [[__Distributed_computing]], [[__Infrastructure_Engineering]] [[_My_projects]]
#kind #Cloud #DevOps #DistributedComputing #DataEngineering #MyProjects 

# Infrastructure monitoring
What to monitor:
- Kubernetes:
    - pod restarts
    - CPU / memory
    - OOM kills
- Spark Thrift Server:
    - CPU / memory
    - active connections
- Airflow:
    - scheduler health
    - worker usage

How:
- Install: `kube-prometheus-stack`
- Add exporters:
    - node-exporter
    - kube-state-metrics
# Airflow workflows execution monitoring
What to monitor:
- DAG success/failure rate
- task duration
- retries
- queue delays
## Option A (best)
Use built-in Prometheus metrics:
```
[metrics]  
statsd_on = True
```
- statsd-exporter → Prometheus
## Option B
Use Airflow exporter
# dbt
What to monitor:
- model failures
- runtime per model
- freshness
- test results
## Option 1 — “Log parsing” (simple, common)
Pipeline:
```
dbt run → run_results.json → Python script → Prometheus Pushgateway
```

Metrics examples:
- `dbt_model_runtime_seconds`
- `dbt_model_status{status="error"}`
- `dbt_tests_failed_total`
## Option 2 — Airflow-driven metrics (cleaner)
Since dbt runs inside Airflow:  
👉 emit metrics directly from DAG
# Spark monitoring
What to monitor:
- job duration
- failed stages
- executor usage
- shuffle size
## Option A (quick win)

Use Spark UI + scrape via exporter
## Option B (better)
Enable Prometheus sink:
spark.metrics.conf.*
# MLflow monitoring
What to monitor:
- experiment rate
- training duration
- failures
- API latency
## Option 1 (quick)
Monitor:
- MLflow server (CPU, memory)
- backend DB
- artifact storage
## Option 2 (better)
Instrument MLflow:
- middleware with Prometheus client
- track:
    - `/runs/create` latency
    - errors
# Model performance monitoring
What to monitor:
- From your metrics table:
	- accuracy / RMSE over time
	- drift indicators
	- prediction distribution
	- retraining frequency
## Option A — DB → Prometheus exporter
- query your metrics table
- expose as metrics:
```
ml_model_accuracy{model="x"} 0.82  
ml_model_drift_score 0.12
```
## Option B — Push metrics during pipeline
Inside Airflow:
- push metrics after prediction job
# Retraining logic monitoring
Monitor:
- Metrics:
	- `model_retraining_triggered_total`
	- `model_retraining_success_total`
	- `model_retraining_duration`
# Business / data quality monitoring
What to track:
- data freshness (dbt sources)
- row counts
- anomalies
- feature distributions

 How:
- dbt tests → Prometheus
- custom checks → metrics