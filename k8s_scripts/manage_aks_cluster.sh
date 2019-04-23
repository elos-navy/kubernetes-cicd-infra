#!/bin/bash

RESOURCE_GROUP='ls-test-rg'
NAME='ls-test-cluster'
LOCATION='westeurope'

function create_rg {
  az group create --name $RESOURCE_GROUP --location $LOCATION
}

function create_cluster {
  az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $NAME \
    --node-count 1 \
    --enable-addons http_application_routing \
    --generate-ssh-keys
}

function setup_credentials {
  rm -f ~/.kube/config
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $NAME
}

#create_rg
#create_cluster
setup_credentials

