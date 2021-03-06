variable resource_group_name {
    default = "azure-k8stest"
}
variable "client_id" {}
variable "client_secret" {}



variable "agent_count" {
    default = 1
}

variable "vm_size" {
  default = "Standard_DS1_v2"
}

variable "ssh_public_key" {
#    default = "~/.ssh/id_rsa.pub"
}       

variable "dns_prefix" {
    default = "k8stest"
}

variable cluster_name {
    default = "k8stest"
}

variable location {
    default = "WestEurope"
}

variable kv_name {
    description = "Key Vault Name"
}

variable kv_rg {
    description = "Key Vault Resource Group Name"
}

variable kv_secret {
    description = "Key Vault Resource Group Name"
    default = "client-secret2"
}