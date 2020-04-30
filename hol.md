# Hands on lab

## Open Bash Shell
https://shell.azure.com

## Set Subscription

``` bash
# Get accounts and show name, subscriptionId and tenantId
az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
```

Output
``` json
[
  {
    "name": "Visual Studio Enterprise – MPN",
    "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  },
  {
    "name": "Microsoft Azure Sponsorship",
    "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
]
```

``` bash 
# Set Account
az account set --subscription $SUBSCRIPTION_ID

# Set Variables
SUBSCRIPTION_ID=# use subscriptionId
TENANT_ID=# use use tenantId
```

## Create Service Principal

This should be done only once.

``` bash
# Create Service Principal
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID"
```

Ouput
``` json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "name": "http://azure-cli-2020-04-30-12-09-36",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Make sure to store Client_Id and Client_Secret. You get this info once

``` bash
# Set Variables
CLIENT_ID=# use appId
CLIENT_SECRET=# use password
```

## Create Key Vault to store client secret

``` bash
# Set Variables
DEF_LOCATION=westeurope
KV_SUFFIX=
KV_NAME=kvk8s$KV_SUFFIX
KV_RG=rg-key-vault$KV_SUFFIX
# Create Resource Group 
az group create -l $DEF_LOCATION -n $KV_RG
# Create Key Vault
az keyvault create --location $DEF_LOCATION --name $KV_NAME --resource-group $KV_RG --enable-soft-delete true

# Create Access Policy
az keyvault set-policy --name $KV_NAME --spn $CLIENT_ID --key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey --secret-permissions backup delete get list purge recover restore set --storage-permissions backup delete deletesas get getsas list listsas purge recover regeneratekey restore set setsas update

# Store Secret
az keyvault secret set --name client-secret --vault-name $KV_NAME --value $CLIENT_SECRET
```

## Get an SSH public key

This should be done only once.

``` bash
# Generate SSH keys
ssh-keygen -m PEM -t rsa -b 4096
```

Just use defaults and press <ENTER> 3 times

``` bash
# Set Variables
SSH_PUBLIC_KEY=$(cat /home/$USER/.ssh/id_rsa.pub)
```

## Create Storage Account For TF State

``` bash
# Set Variables
NAME=# Use Short Unique Identifier Like $USER
RG_STATE_FILES=rg-k8s-state$NAME
STORAGE_ACCOUNT_NAME=k8sstorage123$NAME
CONTAINER_NAME=tfstate
KEY=k8s.tfstate$NAME

# Create Resource Group
az group create -n $RG_STATE_FILES -l $DEF_LOCATION
# Create Storage Account
az storage account create -n $STORAGE_ACCOUNT_NAME -g $RG_STATE_FILES -l $DEF_LOCATION --sku Standard_LRS

# Set Other Variables
ACCESS_KEY=$(az storage account keys list -g $RG_STATE_FILES -n $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)
# Create Storage Container
az storage container create -n $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCESS_KEY

```

## Create Test

Create a small TF file to test if Terraform has been correctly installed

``` bash
cd clouddrive
mkdir test
cd test
code test.tf
```

Paste code and save

``` tf
provider "azurerm" {
  version = "~>2.0"
  features {}
}
```

``` bash
terraform init
```

Ouput 
``` console
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## Create AKS

``` bash
cd ..
mkdir terraform-aks-k8s
cd terraform-aks-k8s
```

### Create main.tf
``` bash
code main.tf
```

Paste code and save
``` tf
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
```

### Create k8s.tf
``` bash
code k8s.tf
```

Paste code and save
``` tf
resource "azurerm_resource_group" "k8s" {
    name     = var.resource_group_name
    location = var.location
}

data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = kv_rg.kv_rg
}

data "azurerm_key_vault_secret" "client_secret" {
name = var.kv_secret
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
```


### Create output.tf
``` bash
code output.tf
```

### Create variables.tf
``` bash
code variables.tf
```

Paste code and save
``` tf
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
    default = "client-secret"
}
```

### Create Module
``` bash
cd
mkdir modules
cd modules
mkdir acme-rg
cd acme-rg
```


### Create main.tf
``` bash
code main.tf
```

Paste code and save
``` tf
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
```

### Create variables.tf
``` bash
code variables.tf
```

Paste code and save
``` tf
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
```

### Create output.tf
``` bash
code output.tf
```

Paste code and save
``` tf
output "client_key" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
}

output "client_certificate" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
}

output "cluster_password" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.password
}

output "kube_config" {
    value = azurerm_kubernetes_cluster.k8s.kube_config_raw
}

output "host" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}
```

### Prepare Terraform

``` bash
# Initalize Environment Variables
export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export ARM_CLIENT_ID=$CLIENT_ID
export ARM_CLIENT_SECRET=$CLIENT_SECRET
export ARM_TENANT_ID=$TENANT_ID
export TF_VAR_client_id=CLIENT_ID
export TF_VAR_client_secret=$CLIENT_SECRET
export TF_VAR_kv_name=$KV_NAME
export TF_VAR_kv_rg=$KV_RG
export TF_VAR_ssh_public_key=$SSH_PUBLIC_KEY

RESOURCE_GROUP_NAME=azure-k8stest
CLUSTER_NAME=k8stest

export TF_VAR_resource_group_name=$RESOURCE_GROUP_NAME
export TF_VAR_cluster_name=$CLUSTER_NAME

# Initialize Terraform
terraform init -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" -backend-config="container_name=$CONTAINER_NAME" -backend-config="access_key=$ACCESS_KEY" -backend-config="key=$KEY"
```

### Plan Terraform

``` bash
# Execute Plan
terraform plan -out out.plan
```

### Apply Terraform

``` bash
# Execute Apply
terraform apply out.plan
```

### Test Cluster
``` bash
# Get config
az aks get-credentials -g $RESOURCE_GROUP_NAME -n $CLUSTER_NAME

# Get Nodes
kubectl get nodes
```

## Destroy Terraform

``` bash
# Delete Resources
terraform destroy
```
