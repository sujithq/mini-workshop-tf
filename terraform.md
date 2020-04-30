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

export TF_VAR_client_id=your_appId

export TF_VAR_client_secret=your_password


## Test

## AKS

### Set Variables
NAME=

RG_STATE_FILES=rg-k8s-state

DEF_LOCATION=westeurope

STORAGE_ACCOUNT_NAME=k8sstorage123

CONTAINER_NAME=tfstate

KEY=k8s.tfstate$NAME


### Create Resource Group

az group create -n $RG_STATE_FILES -l $DEF_LOCATION

### Create Storage Account
az storage account create -n $STORAGE_ACCOUNT_NAME -g $RG_STATE_FILES -l $DEF_LOCATION --sku Standard_LRS

### Get access key
ACCESS_KEY=$(az storage account keys list -g $RG_STATE_FILES -n $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)
ACCESS_KEY=$(echo $(az storage account keys list -g $RG_STATE_FILES -n $STORAGE_ACCOUNT_NAME --query "[0].value") | tr -d '"')

### Create container
az storage container create -n $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCESS_KEY

### Initialize TF
terraform init -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" -backend-config="container_name=$CONTAINER_NAME" -backend-config="access_key=$ACCESS_KEY" -backend-config="key=$KEY"

### Generate ssh key

ssh-keygen -m PEM -t rsa -b 4096

### Plan TF
terraform plan -out out.plan

### Apply TF
terraform apply out.plan

### Get config
export KUBECONFIG=./azurek8s

echo "$(terraform output kube_config)" > ./azurek8s

export KUBECONFIG=./azurek8s


kubectl get nodes