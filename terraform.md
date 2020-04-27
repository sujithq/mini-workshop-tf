# Terraform

## Prerequisites
## Terminal

az login

az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"

az account set --subscription="${SUBSCRIPTION_ID}"  

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"

SET ARM_SUBSCRIPTION_ID="ARM_SUBSCRIPTION_ID"

SET ARM_CLIENT_ID="ARM_CLIENT_ID"

SET ARM_CLIENT_SECRET="ARM_CLIENT_SECRET"

SET ARM_TENANT_ID="ARM_TENANT_ID"

## Cloud Shell

https://shell.azure.com

az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"

export ARM_SUBSCRIPTION_ID=your_subscription_id

export ARM_CLIENT_ID=your_appId

export ARM_CLIENT_SECRET=your_password

export ARM_TENANT_ID=your_tenant_id

## Test
Create directory

Create file

```
provider "azurerm" {
  version = "~>2.0"
  features {}
}
```



az group create -n k8s-state -l westeurope

az storage account create -n k8sstorage123 -g k8s-state -l westeurope --sku Standard_LRS

az storage account keys list -g k8s-state -n k8sstorage123

az storage container create -n tfstate --account-name k8sstorage123 --account-key +2adfUMpKgzrmpLdLAKsLrHBJpp8kEIayCctTeohmjH7N3dQIfXgr1cybokgFdWSwoU8affu1jimSurwGBx1Bg==

terraform init -backend-config="storage_account_name=k8sstorage123" -backend-config="container_name=tfstate" -backend-config="access_key=+2adfUMpKgzrmpLdLAKsLrHBJpp8kEIayCctTeohmjH7N3dQIfXgr1cybokgFdWSwoU8affu1jimSurwGBx1Bg==" -backend-config="key=k8s.tfstate"


export TF_VAR_client_id=07a3c497-f56d-416f-ab06-24fd5e391b7c
export TF_VAR_client_secret=491c7cc9-e7ea-4f5e-9ad8-2e0f9dce27f9

ssh-keygen -m PEM -t rsa -b 4096

terraform plan -out out.plan

terraform apply out.plan

export KUBECONFIG=./azurek8s

echo "$(terraform output kube_config)" > ./azurek8s

export KUBECONFIG=./azurek8s


kubectl get nodes