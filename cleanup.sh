#!/bin/bash

source ./config
source ./functions

kubectl delete namespace ${PREFIX}jenkins
kubectl delete clusterrolebinding jenkins

kubectl delete namespace ${PREFIX}components
kubectl delete namespace ${PREFIX}tasks-dev
kubectl delete namespace ${PREFIX}tasks-prod

#kubectl delete sc ${PREFIX}azurefile

#kubectl delete all,pvc,cm --selector=app=${PREFIX}jenkins
#kubectl delete all,pvc,cm --selector=app=${PREFIX}nexus3
#kubectl delete all,pvc,cm --selector=app=${PREFIX}sonar-postgres
#kubectl delete all,pvc,cm --selector=app=${PREFIX}sonarqube

