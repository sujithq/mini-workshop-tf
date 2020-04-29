resource "azurerm_resource_group" "k8s" {
    name     = var.resource_group_name
    location = var.location
}

data "azurerm_key_vault" "kv" {
  name                = "kvk8s"
  resource_group_name = "rg-key-vault"
}

data "azurerm_key_vault_secret" "client_secret" {
name = "client-secret"
key_vault_id = data.azurerm_key_vault.kv.id
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
    client_secret           = data.azurerm_key_vault_secret.client_secret.value 
}