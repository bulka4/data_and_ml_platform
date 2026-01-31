# This is a Dockerfile for buidling an image for running an Airflow task. Using KubernetesPodOperator, Airflow
# creates a pod using this image and git-sync pulls code from a repo which will be executed in this image.

FROM python:3.11-slim

# RUN mkdir /opt/airflow/dags