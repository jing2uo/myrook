kubectl delete -f pmem/pmem-storageclass-ext4-wffc.yaml
kubectl delete -f pmem/pmem-storageclass-xfs-wffc.yaml
kubectl delete -f pmem/pmem-csi-lvm.yaml


ndctl disable-namespace all
ndctl destroy-namespace all
