from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from kubernetes.client import V1Volume, V1VolumeMount, V1PersistentVolumeClaimVolumeSource, V1EnvVar, V1EnvVarSource, V1SecretKeySelector

from airflow import DAG
from datetime import datetime


# =============== Configuration ===============
image = "dataanalyticsbulka.azurecr.io/airflow-dag:latest" # Include only lowercase letters
script_to_run = "/opt/airflow/dags/project_1/task_1.py"
pvc_name = "airflow-dags-pvc" # Name of the PVC with saved DAGs code (pulled by git-sync)
airflow_logs_url = "wasb://airflow-logs@systemfilesbulka.blob.core.windows.net" # URL of the Storage Account used for saving Airflow logs
conn_id = "azure_blob" # ID of the Airflow connection used for accessing Azure Storage Account for saving Airflow logs



# =============== DAG ===============
default_args = {
    "owner": "airflow"
    ,"start_date": datetime(2026, 1, 1)
}

with DAG(
    "example_pod_with_git_sync"
    ,default_args=default_args
    ,schedule_interval=None
) as dag:

    # Mount the PVC used by git-sync
    dags_volume = V1Volume(
        name='dags-volume'
        ,persistent_volume_claim=V1PersistentVolumeClaimVolumeSource(
            claim_name=pvc_name
        )
    )

    dags_volume_mount = V1VolumeMount(
        name='dags-volume'
        ,mount_path='/opt/airflow/dags'
        ,sub_path='dags'
        ,read_only=True
    )

    task = KubernetesPodOperator(
        task_id="run_task"
        ,name="run-task"
        ,namespace="airflow"
        ,service_account_name="airflow-sa" # K8s Service Account with a secret for pulling images
        ,image=image
        ,volumes=[dags_volume]
        ,volume_mounts=[dags_volume_mount]
        ,cmds=["python", script_to_run]
        ,env_vars={
            "AIRFLOW__LOGGING__REMOTE_LOGGING": "True"
            ,"AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER": airflow_logs_url
            ,"AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID": conn_id
            # Use a secret with a connection string to the metadata db
            ,V1EnvVar(
                name="AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
                ,value_from=V1EnvVarSource(
                    secret_key_ref=V1SecretKeySelector(
                        name="airflow-postgres-connection"
                        ,key="connection"
                    )
                )
            )
        }
    )

    # task = KubernetesPodOperator(
    #     task_id="sanity",
    #     name="sanity",
    #     namespace="airflow",
    #     image="busybox",
    #     cmds=["sh", "-c", "echo hello && sleep 30"],
    #     service_account_name="airflow-sa",
    #     kubernetes_conn_id=None,
    #     is_delete_operator_pod=False,
    # )

