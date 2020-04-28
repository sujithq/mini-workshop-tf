provider "azurerm" {
    version = "~>2.0"
    features {}
}

terraform {
    backend "azurerm" {
        # storage_account_name = "k8sstorage123"
        # container_name = "tfstate"
        # key = "k8s.tfstate"
        # resource_group_name = "rg-k8s-state"
    }

}