kubectl delete -n rook-ceph -f cockroachdb/cluster-init.yaml               --grace-period=0 --force
kubectl delete -n rook-ceph -f cockroachdb/cockroachdb-statefulset.yaml    --grace-period=0 --force
kubectl delete -n rook-ceph -f cosbench/object-bucket-claim-delete.yaml    --grace-period=0 --force
kubectl delete -n rook-ceph -f cosbench/object.yaml                        --grace-period=0 --force
kubectl delete -n rook-ceph -f cosbench/rgw-external.yaml                  --grace-period=0 --force
kubectl delete -n rook-ceph -f cosbench/s3-config.xml                      --grace-period=0 --force
kubectl delete -n rook-ceph -f cosbench/storageclass-bucket-delete.yaml    --grace-period=0 --force
kubectl delete -n rook-ceph -f hammerdb/hammerdb-statefulset.yaml          --grace-period=0 --force
kubectl delete -n rook-ceph -f hammerdb/mysql-statefulset.yaml             --grace-period=0 --force
kubectl delete -n rook-ceph -f rook/cephcsi-storageclass.yaml              --grace-period=0 --force
kubectl delete -n rook-ceph -f rook/cluster-with-pmem.yaml                 --grace-period=0 --force
kubectl delete -n rook-ceph -f rook/cluster-with-ssd.yaml                  --grace-period=0 --force
kubectl delete -n rook-ceph -f rook/common.yaml                            --grace-period=0 --force
kubectl delete -n rook-ceph -f rook/operator.yaml                          --grace-period=0 --force
kubectl delete -n rook-ceph -f rook/ssd-pv.yaml                            --grace-period=0 --force
kubectl delete -n rook-ceph -f rook/ssd-sc.yaml                            --grace-period=0 --force
kubectl delete -n rook-ceph -f rook/toolbox.yaml                           --grace-period=0 --force
