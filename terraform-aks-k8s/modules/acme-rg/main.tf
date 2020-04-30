provider "azurerm" {
    version = "~>2.0"
    features {}
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = var.location
    resource_group_name = var.resource_group_name
    dns_prefix          = var.dns_prefix
    linux_profile {
        admin_username = "ubuntu"
        ssh_key {
            key_data = var.ssh_public_key
        }
    }
    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = var.vm_size
        enable_auto_scaling   = true
        max_count             = 3
        min_count             = 1

    }
    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    tags = {
        Environment = "Development"
    }
}