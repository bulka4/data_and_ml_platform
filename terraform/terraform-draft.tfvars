# Location of the created resource group
resource_group_location = "westeurope"

# Name of the created resource group
resource_group_name = "data_engineering_apps"

# Size of VMs added to the AKS cluster. We can't choose too weak VM because we will get error in Kubernetes that there is not enough resources
# for example for Milvus. The below option is probably the weakest VM which will run our agent.
# node_vm_size = "Standard_D2s_v3" # - 0.09$ per hour, 2 vCPU, 8gb RAM
node_vm_size = "Standard_D4s_v3" # - 0.19$ per hour, 4 vCPU, 16gb RAM
# node_vm_size = "Standard_E4s_v3" # - 0.25$ per hour, 4 vCPU, 32gb RAM

# Number of nodes to create in the AKS cluster.
node_count = 1
