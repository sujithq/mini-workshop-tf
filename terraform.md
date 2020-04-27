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

RG_STATE_FILES=rg-k8s-state

DEF_LOCATION=westeurope

ST_ACCOUNT=k8sstorage123


### Create Resource Group

az group create -n $RG_STATE_FILES -l $DEF_LOCATION

### Create Storage Account
az storage account create -n $ST_ACCOUNT -g $RG_STATE_FILES -l $DEF_LOCATION --sku Standard_LRS

### Get access key
KEY=$(echo $(az storage account keys list -g $RG_STATE_FILES -n $ST_ACCOUNT --query "[0].value") | tr -d '"')

### Create container
az storage container create -n tfstate --account-name $ST_ACCOUNT --account-key $KEY

### Initialize TF
terraform init -backend-config="storage_account_name=$ST_ACCOUNT" -backend-config="container_name=tfstate" -backend-config="access_key=$KEY" -backend-config="key=k8s.tfstate"

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