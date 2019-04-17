#!/bin/bash

PREFIX='cicd-'

kubectl delete namespace ${PREFIX}components
#kubectl delete all,pvc,cm --selector=app=${PREFIX}jenkins
#kubectl delete all,pvc,cm --selector=app=${PREFIX}nexus3
#kubectl delete all,pvc,cm --selector=app=${PREFIX}sonar-postgres
#kubectl delete all,pvc,cm --selector=app=${PREFIX}sonarqube

