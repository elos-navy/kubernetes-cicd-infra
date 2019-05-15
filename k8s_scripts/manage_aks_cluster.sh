#!/bin/bash

source ./config

function create_rg {
  az group create --name $RESOURCE_GROUP --location $LOCATION
}

function delete_rg {
  az group delete --name $RESOURCE_GROUP
}

function create_cluster {
  az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 2 \
    --enable-addons http_application_routing \
    --generate-ssh-keys
}

function delete_cluster {
  az aks delete \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME
}

function create_acr {
  az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $REGISTRY_NAME \
    --admin-enabled true \
    --sku Standard

  az acr credential show \
    --name $REGISTRY_NAME
}

function delete_acr {
  az acr delete \
    --resource-group $RESOURCE_GROUP \
    --name $REGISTRY_NAME
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

function usage {
  cat <<EOF
Usage: $(basename $0) <option>

Options:
  create_rg
  delete_rg
  create_cluster
  delete_cluster
  create_acr
  delete_acr
  setup_credentials

EOF
}

case $1 in
  create_rg)
    create_rg;;
  delete_rg)
    delete_rg;;
  create_cluster)
    create_cluster;;
  delete_cluster)
    delete_cluster;;
  create_acr)
    create_acr;;
  delete_acr)
    delete_acr;;
  setup_credentials)
    setup_credentials;;
  *)
    usage;;
esac
