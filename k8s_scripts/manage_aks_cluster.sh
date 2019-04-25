#!/bin/bash

CLUSTER_NAME='ls-test-cluster'
STORAGE_ACCOUNT_NAME='lsstorageaccount'
LOCATION='westeurope'
RESOURCE_GROUP='ls-test-rg'
SHADOW_RESOURCE_GROUP="MC_${RESOURCE_GROUP}_${CLUSTER_NAME}_${LOCATION}"

function create_rg {
  az group create --name $RESOURCE_GROUP --location $LOCATION
}

function create_cluster {
  az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 1 \
    --enable-addons http_application_routing \
    --generate-ssh-keys
}

function create_storage_account {
  az storage account create \
    --resource-group $SHADOW_RESOURCE_GROUP \
    --name $STORAGE_ACCOUNT_NAME \
    --location $LOCATION
}

function setup_credentials {
  rm -f ~/.kube/config
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
}

#create_rg
#create_cluster
create_storage_account
#setup_credentials

