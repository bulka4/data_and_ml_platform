FROM ubuntu:22.04

# ========== Define build-time variables ==========

# Names of images we will build and push to ACR which will be used when deploying RAG resources on AKS. Those are images for:
# - MCP Server
# - Preparing Milvus db (sample documents with their vector embeddings)
# - Ray Serve app with RAG LangGraph workflow
ARG AIRFLOW_IMAGE_NAME=${airflow_image_name}:${airflow_image_tag}
ARG AIRFLOW_DAG_IMAGE_NAME=${airflow_dag_image_name}:${airflow_dag_image_tag}
ARG SPARK_IMAGE_NAME=${spark_image_name}:${spark_image_tag}
ARG MLFLOW_TRACKING_SERVER_IMAGE_NAME=${mlflow_tracking_server_image_name}:${mlflow_tracking_server_image_tag}
ARG MLFLOW_PROJECT_IMAGE_NAME=${mlflow_project_image_name}:${mlflow_project_image_tag}
# This prevents prompting user for input for example when using apt-get.
ENV DEBIAN_FRONTEND=noninteractive


# Tell Docker to use bash for the rest of the Dockerfile
SHELL ["/bin/bash", "-c"]

WORKDIR /root




# ============ Install Helm, Azure CLI and kubectl =============

# Install Helm
RUN apt-get update && \
    apt-get -y install curl && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


# Install Azure CLI and save credentials to AKS in the ~/.kube/config (kubeconfig) file
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \

    # Login to Azure using CLI using the created Service Principal which has proper permissions for using 'az aks get-credentials'
    # and 'az acr build'.
    az login --service-principal \
      --username ${acr_sp_id} \
      --password ${acr_sp_password} \
      --tenant ${tenant_id} && \

    az account set --subscription ${subscription_id} && \

    # Save credentials to AKS in the ~/.kube/config (kubeconfig) file. That will enable us using kubectl to interact with AKS.
    az aks get-credentials \
      --resource-group ${rg_name} \
      --name ${aks_name}


# Install kubectl for interacting with AKS
RUN apt-get install -y apt-transport-https ca-certificates && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \

    # Add the GPG key and APT repository URL to the kubernetes.list. That url will be used to pull Kubernetes packages (like kubectl)
    <<EOF cat >> /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /
EOF

RUN apt-get update && \
    apt-get install -y kubectl && \
    apt-mark hold kubectl




# ========== Install other useful tools =============
# Install: nano
RUN apt-get install nano




# ============ Create and save a bash script for building and pushing to ACR images =============

# Those images will be used for deploying different parts of the system. Those are images for:
# - Airflow

# Copy Dockerfiles and other files needed for building images
COPY dockerfiles /root/dockerfiles

# Save the script for building images and pushing them to ACR.
RUN <<EOF cat > /root/apps/build_and_push.sh
az acr build \
  --registry ${acr_name} \
  --resource-group ${rg_name} \
  --image $AIRFLOW_IMAGE_NAME \
  --file /root/dockerfiles/airflow.Dockerfile \
  /root/dockerfiles
  
az acr build \
  --registry ${acr_name} \
  --resource-group ${rg_name} \
  --image $AIRFLOW_DAG_IMAGE_NAME \
  --file /root/dockerfiles/airflow.dag.Dockerfile \
  /root/dockerfiles

az acr build \
  --registry ${acr_name} \
  --resource-group ${rg_name} \
  --image $SPARK_IMAGE_NAME \
  --file /root/dockerfiles/spark.thrift.server.Dockerfile \
  /root/dockerfiles

az acr build \
  --registry ${acr_name} \
  --resource-group ${rg_name} \
  --image $MLFLOW_TRACKING_SERVER_IMAGE_NAME \
  --file /root/dockerfiles/mlflow.tracking.server.Dockerfile \
  /root/dockerfiles

az acr build \
  --registry ${acr_name} \
  --resource-group ${rg_name} \
  --image $MLFLOW_PROJECT_IMAGE_NAME \
  --file /root/dockerfiles/mlflow.project.Dockerfile \
  /root/dockerfiles/mlflow_project
EOF

RUN \
    # Remove the '\r' sign from the script
    sed -i 's/\r$//' /root/apps/build_and_push.sh && \
    # Make the script executable
    chmod +x /root/apps/build_and_push.sh




# ============ Copy the folder with Helm charts for deploying all the resources needed for RAG workflow ==============
COPY helm_charts /root/helm_charts




# Run the script for building and pushing images to ACR and start a bash session
# CMD ["bash", "-c", "/root/apps/build_and_push.sh && /bin/bash"]