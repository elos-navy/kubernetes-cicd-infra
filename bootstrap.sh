#!/bin/bash

source ./config
source ./functions

TMP_DIR=$(mktemp -d)

while [[ $# > 0 ]]
do
  KEY="$1"
  shift
  case "$KEY" in
    --registry_name)
      REGISTRY_NAME="$1"
      shift
      ;;
    --cluster_name)
      CLUSTER_NAME="$1"
      shift
      ;;
    --location)
      LOCATION="$1"
      shift
      ;;
    --resource_group)
      RESOURCE_GROUP="$1"
      shift
      ;;
    --jenkins_admin_password)
      JENKINS_ADMIN_PASSWORD="$1"
      shift
      ;;
    --application_git_url)
      APPLICATION_GIT_URL="$1"
      shift
      ;;
    *)
      echo "ERROR: Unknown argument '$KEY' to script '$0'" 1>&2
      exit 1
  esac
done

set -x

enable_routing_part_1
enable_routing_part_2

# Jenkins Namespace
create_from_template templates/jenkins-namespace.yaml \
  _PREFIX_ $PREFIX
kubectl config set-context $(kubectl config current-context) --namespace=${PREFIX}jenkins


# Storage Class (Azure File for ReadWriteMany PV types)
#create_from_template templates/azure-file-storage-class.yaml \
#  _PREFIX_ $PREFIX \
#  _STORAGE_ACCOUNT_ $STORAGE_ACCOUNT_NAME


# Jenkins
create_from_template templates/jenkins-persistent.yaml \
  _PREFIX_ $PREFIX \
  _JENKINS_ADMIN_PASSWORD_ "$JENKINS_ADMIN_PASSWORD" \
  _APPLICATION_GIT_URL_ "$APPLICATION_GIT_URL" \
  _REGISTRY_NAME_ "$REGISTRY_NAME" \
  _REGISTRY_SECRET_NAME_ "$REGISTRY_SECRET_NAME" \
  _COMPONENTS_PIPELINE_JOB_NAME_ 'cicd-components-pipeline' \
  _APP_PIPELINE_JOB_NAME_ 'cicd-app-pipeline'

create_from_template templates/ingress/ingress.yaml \
  _DNS_NAME_ 'jenkins' \
  _DNS_DOMAIN_ "$DNS_ZONE_NAME" \
  _NAMESPACE_ "${PREFIX}jenkins" \
  _LOCATION_ 'westeurope' \
  _SERVICE_NAME_ "${PREFIX}jenkins" \
  _SERVICE_PORT_ 8080

# Build and push Jenkins agent POD to ACR registry
az acr build -t ${PREFIX}jenkins/jenkins-agent-appdev:latest -r $REGISTRY_NAME artefacts/


# Set k8s secret for pulling images from ACR registry
ACR_CREDENTIALS=$(az acr credential show -n $REGISTRY_NAME)
ACR_USERNAME=$(echo $ACR_CREDENTIALS | jq '.username' | sed 's/"//g')
ACR_PASSWORD=$(echo $ACR_CREDENTIALS | jq '.passwords[0].value' | sed 's/"//g')
ACR_HOSTNAME=$(az acr show -n $REGISTRY_NAME | jq '.loginServer' | sed 's/"//g')
kubectl create secret docker-registry $REGISTRY_SECRET_NAME \
    --docker-server=$ACR_HOSTNAME \
    --docker-username=$ACR_USERNAME \
    --docker-password=$ACR_PASSWORD \
    --docker-email='ls@elostech.cz'


rm -rf $TMP_DIR
