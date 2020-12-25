#!/bin/bash

kubectl delete -f toolbox.yaml --grace-period=0 --force
kubectl delete -f cephcsi-storageclass.yaml --grace-period=0 --force
kubectl delete -f cluster-with-ssd.yaml --grace-period=0 --force
kubectl delete -f cluster-with-pmem.yaml --grace-period=0 --force
kubectl delete -f cluster-with-cas.yaml --grace-period=0 --force
kubectl delete -f operator.yaml --grace-period=0 --force
kubectl delete -f common.yaml --grace-period=0 --force
kubectl delete -f ssd-sc.yaml --grace-period=0 --force
kubectl delete -f ssd-pv.yaml --grace-period=0 --force
