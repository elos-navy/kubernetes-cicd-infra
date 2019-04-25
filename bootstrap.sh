#!/bin/bash

PREFIX='cicd-'
STORAGE_ACCOUNT='lsteststorageaccount'
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

# Jenkins Namespace
create_from_template templates/jenkins-namespace.yaml \
  _PREFIX_ $PREFIX
kubectl config set-context $(kubectl config current-context) --namespace=${PREFIX}jenkins

# Storage Account
create_from_template templates/azure-file-storage-class.yaml \
  _PREFIX_ $PREFIX \
  _STORAGE_ACCOUNT_ $STORAGE_ACCOUNT
#kubectl create -f templates/azure-storage-secret.yaml


# Jenkins
create_from_template templates/jenkins-persistent.yaml \
  _PREFIX_ $PREFIX

rm -rf $TMP_DIR
