# Resource Group
module resource_group {
    source = "./modules/resource_group"
    name     = var.resource_group_name
    location = var.location
}


# Log Analytics workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "law" {
  name                = "aks-law"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  dns_prefix          = "${var.aks_name}-dns"

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size

    # os_type, and other options can be customized
    type                = "VirtualMachineScaleSets"
    os_disk_size_gb     = 256
    enable_auto_scaling = false
    # For production, consider using node labels, taints, and autoscaling
  }

  # An AD identity which can be used by AKS to access other Azure resources.
  identity {
    type = "SystemAssigned"
  }

  # Set up a OMS Agent which sents container monitoring data to the Log Analytics Workspace.
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  # Enable RBAC authorization in a cluster. We will be able to create Roles and Roles Bindings in a cluster.
  role_based_access_control_enabled = true

  network_profile {
    network_plugin = "azure"          # azure CNI; use "kubenet" if desired
    load_balancer_sku = "standard"
    outbound_type = "loadBalancer"
  }

  kubernetes_version = var.kubernetes_version

  tags = {
    environment = "dev"
    created_by  = "terraform"
  }
}


# Create an ACR where we will be storing a Docker image used for deploying all the apps.
module "acr" {
  source = "./modules/acr"
  acr_name                = var.acr_name
  resource_group_name     = var.resource_group_name
  resource_group_location = var.location
}


# Storage account for system files:
#   - Airflow logs
locals {
  system_files_sa_name = "systemfilesbulka"
}

module "system_files_sa" {
  source = "./modules/storage_account"
  resource_group_name = module.resource_group.name
  resource_group_location = module.resource_group.location
  storage_account_name = local.system_files_sa_name
}


# Container for Airflow logs
locals {
  airflow_logs_container_name = "airflow-logs"
}

module "airflow_logs_container" {
  source = "./modules/sa_container"
  name = local.airflow_logs_container_name
  storage_account_name = module.system_files_sa.name
}



# Storage account for containers:
#   - DWH - Data warehouse data
#   - mlflow - MLflow artifacts
module "dwh_sa" {
  source = "./modules/storage_account"
  resource_group_name = module.resource_group.name
  resource_group_location = module.resource_group.location
  storage_account_name = "dwhbulka"
}

# Container for DWH (data warehouse). We will keep there data used for Spark calculations.
module "dwh_container" {
  source = "./modules/sa_container"
  name = "dwh"
  storage_account_name = module.dwh_sa.name
}

# Container for MLflow artifacts
module "mlflow_container" {
  source = "./modules/sa_container"
  name = "mlflow"
  storage_account_name = module.dwh_sa.name
}


# Service Principal for authentication. It is going to have assigned the following roles and scopes:
# - Role 'acrpush' with scope for ACR - Enable pulling images from ACR when deploying pods on Kubernetes
# - Role 'Contributor' with scope for ACR - Enable pushing images to ACR using Azure CLI
# - Role 'Azure Kubernetes Service Cluster User Role' with scope for AKS - Enable getting credentials to AKS (creating .kube/config file)
#   using the 'az aks get-credentials' command.
# - Role 'Storage Blob Data Contributor' - Enable saving data in a Storage Accounts (both with system files and the DWH one)

module "service_principal" {
  source = "./modules/service_principal"
  service_principal_display_name = "rag_workflow"
  role_assignments = [
    {role = "acrpush", scope = module.acr.id}
    ,{role = "Contributor", scope = module.acr.id}
    ,{role = "Azure Kubernetes Service Cluster User Role", scope = azurerm_kubernetes_cluster.aks.id}
    ,{role = "Storage Blob Data Contributor", scope = module.system_files_sa.id}
    ,{role = "Storage Blob Data Contributor", scope = module.dwh_sa.id}
  ]
}



# Create files content which will be saved on the localhost:
# - Dockerfile for creating an image for interacting with AKS
# - values.yaml files for Helm charts
locals {
  # Names and tags of images we will be pushing to ACR and using in Helm charts
  airflow_image_name = "airflow"
  airflow_image_tag = "latest"

  airflow_dag_image_name = "airflow-dag"
  airflow_dag_image_tag = "latest"

  spark_image_name = "spark-thrift-server"
  spark_image_tag = "latest"

  mlflow_tracking_server_image_name = "mlflow-tracking-server"
  mlflow_tracking_server_image_tag = "latest"

  mlflow_project_image_name = "mlflow-project"
  mlflow_project_image_tag = "latest"

  acr_secret_name = "acr-secret"  # Name of the Kubernetes secret which will be used for accessing ACR


  # Dockerfile for interacting with AKS
  dockerfile_interacting_aks = templatefile("template_files/docker/template.interacting.aks.Dockerfile", {
    rg_name         = module.resource_group.name
    aks_name        = azurerm_kubernetes_cluster.aks.name

    acr_sp_id       = module.service_principal.client_id
    acr_sp_secret = module.service_principal.client_secret
    acr_name        = module.acr.name
    
    tenant_id       = data.azurerm_client_config.current.tenant_id
    subscription_id = data.azurerm_client_config.current.subscription_id

    airflow_image_name  = local.airflow_image_name
    airflow_image_tag   = local.airflow_image_tag

    airflow_dag_image_name  = local.airflow_dag_image_name
    airflow_dag_image_tag   = local.airflow_dag_image_tag

    spark_image_name  = local.spark_image_name
    spark_image_tag   = local.spark_image_tag

    mlflow_tracking_server_image_name = local.mlflow_tracking_server_image_name
    mlflow_tracking_server_image_tag  = local.mlflow_tracking_server_image_tag

    mlflow_project_image_name = local.mlflow_project_image_name
    mlflow_project_image_tag = local.mlflow_project_image_tag
  })


  # values.yaml for the Airflow Helm chart
  airflow_chart_values = templatefile("template_files/helm_charts/values-airflow.yaml", {
    acr_url             = module.acr.url
    airflow_image_name  = local.airflow_image_name
    airflow_image_tag   = local.airflow_image_tag

    airflow_kubernetes_namespace = "airflow"
    
    airflow_logs_sa_name        = local.system_files_sa_name        # Name of the Storage Account where logs will be saved
    airflow_logs_container_name = local.airflow_logs_container_name # Name of the container where logs will be saved

    repo_url  = "https://github.com/bulka4/data_and_ml_platform.git"      # URL of the repository with code with Airflow DAGs (https://github.com/<org-name>/<repo-name>.git)
    branch    = "main"                                                    # Branch with the code to run
    # sub_path  = "apps/airflow/dags"                                     # Folder with the code to run
    repo_dags_folder_path = "data_and_ml_platform.git/apps/airflow/dags"  # <repo-name>.git/path/to/dags/folder (e.g. repo_name.git/apps/airflow/dags)

    storage_account_secret = "airflow-azure-blob" # Name of the secret with credentials for accessing Storage Account (to create a connection)
    acr_secret_name = "acr-secret"
  })


  # values.yaml for the Spark Thrift Server Helm chart
  thrift_server_values = templatefile("template_files/helm_charts/values-thrift-server.yaml", {
    spark_image_name = local.spark_image_name

    sa_name        = module.dwh_sa.name        # Name of the Storage Account where data used for Spark calculations will be saved
    sa_container_name = module.dwh_container.name # Name of the container where data used for Spark calculations will be saved
  })


  # values.yaml for the MLflow setup Helm chart
  mlflow_setup_values = templatefile("template_files/helm_charts/values-mlflow-setup.yaml", {
    namespace = "mlflow"
    service_account_name = "mlflow-project-sa"
    tracking_server_service_name = "tracking-server-service"
    
    mlflow_storage_account_name       = module.dwh_sa.name           # Storage Account for storing artifacts
    mlflow_container                  = module.mlflow_container.name # Container for storing artifacts
    sa_secret_name                    = "mlflow-sa"                  # Name of the Kubernetes secret with the Storage Account access key
    sa_access_key_secret_key          = "access_key"                 # Name of the key in the Kubernetes secret with the Storage Account access key

    acr_secret_name = local.acr_secret_name
    acr_url         = module.acr.url
    acr_sp_id       = module.service_principal.client_id
    acr_sp_secret   = module.service_principal.client_secret

    mysql_secret_name               = "mlflow-mysql"  # Name of the Kubernetes secret with credentials for the MySQL user
    mysql_user_password_secret_key  = "user_password" # Name of the key in the secret with the password of the user

    tracking_server_image_name = local.mlflow_tracking_server_image_name
  })


  # values.yaml for the MLflow project Helm chart
  mlflow_project_values = templatefile("template_files/helm_charts/values-mlflow-project.yaml", {
    namespace = "mlflow"
    service_account_name = "mlflow-project-sa"
    tracking_server_service_name = "tracking-server-service"

    acr_url                     = module.acr.url
    mlflow_project_image_name   = local.mlflow_project_image_name
    mlflow_project_image_tag    = local.mlflow_project_image_tag

    repo_url  = "https://github.com/bulka4/data_and_ml_platform.git"  # URL of the repository with code with MLflow projects to run (https://github.com/<org-name>/<repo-name>.git)
    branch    = "main"                                                # Branch with the code to run
    sub_path  = "apps/mlflow/project"                                 # Path to a folder with a project to run
  })


  # create_k8s_secrets.bash script for creating Kubernetes secrets
  create_k8s_secrets = templatefile("template_files/create_k8s_secrets_template.bash", {
    acr_url               = module.acr.url                                  # ACR URL (<registry-name>.azurecr.io)
    client_id             = module.service_principal.client_id              # Service Principal client ID
    client_secret         = module.service_principal.client_secret          # Service Principal client secret
    tenant_id             = data.azurerm_client_config.current.tenant_id    # Azure tenant ID
    storage_account_name  = module.system_files_sa.name                     # Name of the Storage Account used for Airflow logs

    acr_secret_name = "acr-secret"
  })
}


# Save files on the localhost
resource "local_file" "local_files" {
  # each.key - content to save in a file
  # each.value - path where to save a file
  for_each = {
    0 = {content = local.dockerfile_interacting_aks, path = "../interacting.aks.Dockerfile"}
    1 = {content = local.airflow_chart_values, path = "../helm_charts/airflow/values.yaml"}
    2 = {content = local.thrift_server_values, path = "../helm_charts/spark_thrift_server/values.yaml"}
    3 = {content = local.mlflow_setup_values, path = "../helm_charts/mlflow_setup/values.yaml"}
    4 = {content = local.mlflow_project_values, path = "../helm_charts/mlflow_project/values.yaml"}
    5 = {content = local.create_k8s_secrets, path = "../create_k8s_secrets.bash"}
  }

  content = each.value.content
  filename = each.value.path
}


# Get info about the current client to get subscription ID
data "azurerm_client_config" "current" {}