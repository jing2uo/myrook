#!/bin/bash
kubectl apply -f common.yaml
kubectl apply -f operator.yaml
kubectl apply -f local-sc.yaml
kubectl apply -f cas-pv.yaml
#  kubectl apply -f ssd-pv.yaml
#  kubectl apply -f cluster-with-ssd.yaml
#  kubectl apply -f cluster-with-pmem.yaml
#  kubectl apply -f cluster-with-cas.yaml
kubectl apply -f toolbox.yaml
kubectl apply -f cephcsi-storageclass.yaml
