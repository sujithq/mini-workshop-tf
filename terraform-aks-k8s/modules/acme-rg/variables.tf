variable cluster_name {
    description = "Cluster Name"
}

variable resource_group_name {
    description = "Resource Group Name"
}

variable location {
    description = "Location"
    default = "westeurope"
}

variable ssh_public_key {
    description = "Public Key"
}

variable agent_count {
    description = "Node Count"
    default = 3
}

variable vm_size {
    description = "VM Size"
}

variable client_id {
    description = "Client Id"
}

variable client_secret {
    description = "Client Secret"
}

variable dns_prefix {
    description = "DNS Prefix"
}

variable kv_name {
    description = "Key Vault Name"
}

variable kv_rg {
    description = "Key Vault Resource Group Name"
}