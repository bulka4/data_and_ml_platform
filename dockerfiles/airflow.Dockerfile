# Dockerfile for building an image for running Airflow

FROM apache/airflow:2.8.1

RUN pip install \
	apache-airflow-providers-microsoft-azure # To use the connection to Storage Account to save logs there