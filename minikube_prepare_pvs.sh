#!/bin/bash

for i in $(seq 1 20)
do

minikube ssh mkdir -p /data/pv$i
minikube ssh chmod 777 /data/pv$i

if [ $i -lt 10 ]; then
  ACCESS_MODE='ReadWriteOnce'
else
  ACCESS_MODE='ReadWriteMany'
fi

echo "
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv$i
spec:
  accessModes:
    - $ACCESS_MODE
  persistentVolumeReclaimPolicy: Recycle
  capacity:
    storage: 5Gi
  hostPath:
    path: /data/pv$i/" | kubectl create -f -
done
