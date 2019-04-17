#!/bin/bash

PREFIX='cicd-'
TMP_DIR=$(mktemp -d)

function create_from_template {
  FILE=$1; shift

  if [ ! -f "$FILE" ]; then
    echo "ERROR: File '$FILE' doesn't exist!"
    exit 1
  fi

  set -x
  cp $FILE "${TMP_DIR}/$(basename $FILE)"

  while (( "$#" )); do
    #echo "Replacing parameter: $1 -> $2"
    sed -i 's@'$1'@'$2'@g' "${TMP_DIR}/$(basename $FILE)"
    shift
    shift
  done

  kubectl create -f "${TMP_DIR}/$(basename $FILE)"
  set +x
}

# Components Namespace
kubectl create ns ${PREFIX}components
kubectl config set-context $(kubectl config current-context) --namespace=${PREFIX}components

# Jenkins
kubectl create -f jenkins-service-account.yml
create_from_template jenkins-persistent.yaml \
  _PREFIX_ $PREFIX

# Nexus
#create_from_template nexus.yaml \
#  _PREFIX_ $PREFIX

# Sonarqube
#create_from_template postgresql-persistent.yaml \
#  _PREFIX_ ${PREFIX}sonar- \
#  _POSTGRES_DB_ sonar \
#  _POSTGRES_USER_ sonar \
#  _POSTGRES_PASSWORD_ sonar \
#  _DATABASE_SERVICE_NAME_ postgresql-sonarqube

#create_from_template sonarqube.yaml \
#  _PREFIX_ $PREFIX

# Dev environment

# Prod environment

rm -rf $TMP_DIR
