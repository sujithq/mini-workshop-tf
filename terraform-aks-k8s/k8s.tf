resource "azurerm_resource_group" "k8s" {
    name     = var.resource_group_name
    location = var.location
}

module "acme-rg" {
    source                  = "./modules/acme-rg"
    cluster_name            = var.cluster_name
    location                = azurerm_resource_group.k8s.location
    resource_group_name     = azurerm_resource_group.k8s.name
    dns_prefix              = var.dns_prefix 
    ssh_public_key          = var.ssh_public_key 
    agent_count             =  var.agent_count
    vm_size                 = var.vm_size 
    client_id               = var.client_id 
    client_secret           = var.client_secret 
}