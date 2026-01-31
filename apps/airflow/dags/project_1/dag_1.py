from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from kubernetes.client import V1Volume, V1VolumeMount, V1PersistentVolumeClaimVolumeSource

from airflow import DAG
from datetime import datetime


# =============== Configuration ===============
image = "myacr.azurecr.io/airflow-dag:latest"
script_to_run = "/opt/airflow/dags/project_1/dag_1.py"



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
            claim_name='airflow-dags-pvc'
        )
    )

    dags_volume_mount = V1VolumeMount(
        name='dags-volume'
        ,mount_path='/opt/airflow/dags'  # same path as git-sync
        ,read_only=True
    )

    task = KubernetesPodOperator(
        task_id="run_task"
        ,name="run-task"
        ,namespace="airflow"
        ,image=image
        ,volumes=[dags_volume]
        ,volume_mounts=[dags_volume_mount]
        ,cmds=["python", script_to_run]
    )
