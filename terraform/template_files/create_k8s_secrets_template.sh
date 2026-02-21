# user, password and database we create in PostgreSQL which will be used by Airflow
POSTGRES_USER=airflow
POSTGRES_PASSWORD=airflow
POSTGRES_DB=airflow

AIRFLOW_POSTGRES_SECRET=airflow-postgres    # secret used for the PostgreSQL deployment
AIRFLOW_POSTGRES_CONNECTION_SECRET=airflow-postgres-connection  # secret used by Airflow to connect to PostgreSQL
POSTGRES_DNS=airflow-postgres   # DNS name of PostgreSQL (name of the kubernetes service we will create for Postgres deployment)



# Create namespaces and a secret for pulling images from ACR. It uses credentials of a Service Principal with proper permissions
# ('acrpush' role). We have here the following arguments:
	# - docker-server: ACR URL (<registry-name>.azurecr.io)
	# - docker-username: Service Principal client ID
	# - docker-password: Service Principal client secret
	# - docker-email: It doesn't matter what we put here but it is needed
for ns in "airflow" "spark" "mlflow"; do
	kubectl create namespace $ns
	
	kubectl create secret docker-registry ${acr_secret_name} \
		--namespace $ns \
		--docker-server=${acr_url} \
		--docker-username=${client_id} \
		--docker-password=${client_secret} \
		--docker-email=unused@example.com
done


# ===================== Airflow =====================

# Create a secret used by Airflow to access Storage Account to save logs there. 
# It uses credentials of a Service Principal with proper permissions.
# account_name is a name of the Storage Account for Airflow logs
kubectl create secret generic airflow-azure-blob \
  --from-literal=azurestorageaccountname=${system_files_sa} \
  --from-literal=azurestorageaccountkey=${system_files_sa_key} \
  -n airflow


# Create a secret used by Airflow to connect to PostgreSQL metadata db
kubectl create secret generic airflow-postgres-connection \
	--from-literal=connection=postgresql://$${POSTGRES_USER}:$${POSTGRES_PASSWORD}@$${POSTGRES_DNS}:5432/$${POSTGRES_DB} \
	-n airflow


# Create a secret used by PostgreSQL deployment (to create a user and database used by Airflow)
kubectl create secret generic airflow-postgres \
	--from-literal=postgres_user=$${POSTGRES_USER} \
	--from-literal=postgres_password=$${POSTGRES_PASSWORD} \
	--from-literal=postgres_database=$${POSTGRES_DB} \
	-n airflow




# ===================== Spark =====================

# Service Principal's credentials which will be used by Spark and Hive to connect to the Storage Account.
# They will be used in the spark-defaults.conf and core-site.xml files
kubectl create secret generic adls-sp-secret \
  --from-literal=client-id=${client_id} \
  --from-literal=client-secret=${client_secret} \
  --from-literal=tenant-id=${tenant_id} \
  --from-literal=storage-account=${dwh_sa} \
  --from-literal=sa-access-key=${dwh_sa_access_key}
  -n spark

# Secret for Hive Metastore for accessing PostgreSQL metadata db:
kubectl create secret generic hive-metastore-db-secret \
  --from-literal=hive-password=hivepassword \
  --from-literal=postgres-password=adminpassword \
  -n spark