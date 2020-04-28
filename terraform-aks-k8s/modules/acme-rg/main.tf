provider "azurerm" {
    version = "~>2.0"
    features {}
}

resource "azurerm_resource_group" "k8s" {
    name     = var.name
    location = var.location
}