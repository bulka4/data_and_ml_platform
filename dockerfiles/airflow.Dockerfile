# Dockerfile for building an image for running Airflow

FROM apache/airflow:2.9.1-python3.10

# microsoft-azure - To use the connection to Storage Account to save logs there
# cncf-kubernetes - To use KubernetesPodOperator
# apache-airflow-providers-fab - To start Airflow
# --constraint option makes sure that all the packages we install are compatible with airflow 2.9.1 and Python 3.10
# USER airflow
RUN pip install \
	apache-airflow-providers-microsoft-azure==10.0.0 \
	apache-airflow-providers-cncf-kubernetes==8.1.1 \
    apache-airflow-providers-fab==1.0.4 \
	--constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.9.1/constraints-3.10.txt"