Tags: [[_My_projects]]
#MyProjects 

# Introduction
We monitor ML model performance over time as new data arrives. 

We save ML models predictions in tables (as described here - [[Data and ML platform project - Making and saving predictions|link]]) and use them to:
- Perform calculations described below to calculate metrics 
- Save those metrics in tables
- Use saved metrics to decide whether or not a model needs retraining.

We perform those calculations using dbt whenever possible and Python for more complex calculations, and save results in tables.
# Metrics for monitoring
This section describes metrics we can calculate and save in table which will be then used to decide whether or not a model needs retraining.
## Model performance
Model performance metrics:
- Accuracy, RMSE etc
## Prediction behavior
Check:
- Prediction mean
- Prediction variance
- Class balance
- Confidence distribution
- feature importance drift monitoring
- SHAP value drift

If those values changes significantly, something might be wrong.

We can calculate some of those values using dbt, and more complicated ones using Python. Results will be saved in a separate table from where can be used for monitoring.
## Data drift
Check for new data:
- Feature distributions
- Null rates
- Cardinality
- Summary stats
- KL divergence
- Wasserstein distance

and compare it with the data used for training. If those values are different, then model can start making worse predictions.

This way we can detect problems with predictions before they appear.
# Calculating and saving metrics
Metrics are calculated by dbt as described here - [[Data and ML platform project - Data transformation workflow (dev, kind)|link]] in the 'Build tables with ML metrics' section.
# Prometheus / Grafana for monitoring
Use Prometheus / Grafana for monitoring those metrics.