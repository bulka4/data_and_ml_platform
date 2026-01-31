# Location of the created resource group
resource_group_location = "westeurope"

# Name of the created resource group
resource_group_name = "data_engineering_apps"

# Size of VMs added to the AKS cluster. We can't choose too weak VM because we will get error in Kubernetes that there is not enough resources
# for example for Milvus. The below option is probably the weakest VM which will run our app.
node_vm_size = "Standard_D4s_v3"
# node_vm_size = "Standard_E4s_v3"

# Number of nodes to create in the AKS cluster.
node_count = 2