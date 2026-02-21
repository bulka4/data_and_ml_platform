variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "resource_group_location" {
    type = string
    description = "Name of a location the resource group"
}

variable "storage_account_name" {
    type = string
    description = "Name of the created storage account"
}

variable "gen2" {
    type = bool
    description = "Whether or not to enable ADLS Gen2 (if not, then we will create a standard Blob)"
    default = false
}