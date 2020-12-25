# Intel pmem ceph 性能测试



### 硬件信息

| 主机 ip       | CPU                                                          | 傲腾内存 | Sata SSD |
| ------------- | ------------------------------------------------------------ | -------- | -------- |
| 192.168.32.29 | 2 * Intel(R) Xeon(R) Gold 6252N CPU @ 2.30GHz ( 96 cpus )    | 512G     | 800G * 3 |
| 192.168.32.30 | 2 * Intel(R) Xeon(R) Gold 6252N CPU @ 2.30GHz ( 96 cpus )    | 512G     | 800G * 3 |
| 192.168.32.31 | 2 * Intel(R) Xeon(R) Platinum 8280L CPU @ 2.70GHz ( 112 cpus ) | 512G     | 800G * 3 |

### 软件信息

- 操作系统 CentOS Linux release 7.8.2003 (Core)

- 内核版本 3.10.0-1160.6.1.el7.x86_64

- Docker 版本 19.03.9

- Kubernetes 版本 v1.18.13

- Ceph 版本 Octopus 15.2.2

- Ceph 集群 3 节点，18 OSD

- Rook 版本 1.3.3


### 代码

```shell
git clone https://github.com/jing2uo/myrook.git


```


### 场景一：用傲腾非易失性内存加速 Ceph 及上层业务

#### case 1:  只使用 SSD 存储  Data 

##### 部署过程

```shell
# 清理磁盘和遗留文件，编辑 clean.sh 修改 for 循环语句部分的盘符
# 执行脚本会将磁盘全部擦除，并划分两个 372G 的分区，请确保写对
...
for i in "sdb" "sdd" "sdf"
...
```

```shell
# 部署 rook operator
cd rook
kubectl apply -f common.yaml
kubectl apply -f operator.yaml

# 确保创建 pv 使用的节点 ip、磁盘信息和具体环境一致
kubectl apply -f ssd-pv.yaml

# 部署 ceph 集群
kubectl apply -f ssd-sc.yaml
kubectl apply -f cluster-with-ssd.yaml
kubectl apply -f toolbox.yaml
kubectl apply -f cephcsi-storageclass.yaml
```
```shell
# 对象存储部分
kubectl create -n rook-ceph  -f cosbench/object.yaml
kubectl create -n rook-ceph  -f cosbench/object-bucket-claim-delete.yaml
kubectl create -n rook-ceph  -f cosbench/storageclass-bucket-delete.yaml
kubectl create -n rook-ceph  -f cosbench/rgw-external.yaml
```

##### cockroach 测试过程

```shell
kubectl create -n rook-ceph -f cockroachdb-statefulset.yaml
kubectl create -n rook-ceph  -f cluster-init.yaml
kubectl exec -n rook-ceph cockroachdb-0 -ti bash
# 进入容器后执行
cockroach workload init bank --drop
cockroach workload run bank  --duration=300s

cockroach workload init movr --drop
cockroach workload run movr --duration=300s

cockroach workload init tpcc --drop
cockroach workload run tpcc --duration=300s

cockroach workload init ycsb --drop
cockroach workload run ycsb --duration=300s
```

##### cockroach 测试结果

```shell
# bank 部分结果
_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0         151311          504.4    437.8     12.1    520.1  14495.5  94489.3  transfer

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__result
  300.0s        0         151311          504.4    437.8     12.1    520.1  14495.5  94489.3  
```

```shell
# movr 部分结果
_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            977            3.3      5.5      5.2      7.3     15.7     35.7  addUser

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            316            1.1      8.6      8.4     10.5     15.2     18.9  addVehicle

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            340            1.1      9.6      9.4     11.5     17.8     24.1  applyPromoCode

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            101            0.3      5.5      5.5      7.3     14.7     15.2  createPromoCode

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            239            0.8      5.6      5.2      7.3     15.7     17.8  endRide

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0          63421          211.4      1.0      1.0      1.3      1.5     60.8  readVehicles

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0           1303            4.3     15.0     15.2     18.9     26.2     39.8  startRide

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0           3276           10.9     62.2     60.8     79.7    167.8    285.2  updateActiveRides

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__result
  300.0s        0          69973          233.2      4.3      1.0     17.8     71.3    285.2  
```

```shell
# tpcc 部分结果
_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0              5            0.0     51.0     52.4     56.6     56.6     56.6  delivery

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0             63            0.2     31.4     31.5     39.8     44.0     71.3  newOrder

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0              7            0.0      5.3      5.2      6.6      6.6      6.6  orderStatus

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0             61            0.2     23.3     17.8     60.8    104.9    130.0  payment

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0              5            0.0     16.7     16.8     19.9     19.9     19.9  stockLevel

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__result
  300.0s        0            141            0.5     26.8     26.2     52.4    104.9    130.0  
Audit check 9.2.1.7: SKIP: not enough delivery transactions to be statistically significant
Audit check 9.2.2.5.1: SKIP: not enough orders to be statistically significant
Audit check 9.2.2.5.2: SKIP: not enough orders to be statistically significant
Audit check 9.2.2.5.3: PASS
Audit check 9.2.2.5.4: PASS
Audit check 9.2.2.5.5: SKIP: not enough payments to be statistically significant
Audit check 9.2.2.5.6: SKIP: not enough order status transactions to be statistically significant

_elapsed_______tpmC____efc__avg(ms)__p50(ms)__p90(ms)__p95(ms)__p99(ms)_pMax(ms)
  300.0s       12.6  98.0%     31.4     31.5     39.8     39.8     44.0     71.3
```

```shell
# ycsb 部分结果
_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0       14470912        48235.7      3.9      1.0     15.2     60.8    738.2  read

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0         759249         2530.8     13.7      8.9     39.8     92.3   1275.1  update

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__result
  300.0s        0       15230161        50766.5      4.4      1.1     16.8     65.0   1275.1  
```

##### hammerdb 测试过程

```shell
docker pull mysql:latest
docker tag mysql:latest 192.168.32.30:60080/cephtest/mysql:latest
docker push 192.168.32.30:60080/cephtest/mysql:latest
cd hammerdb
kubectl create -n rook-ceph -f hammerdb-statefulset.yaml
kubectl create -n rook-ceph -f mysql-statefulset.yaml 

# 进入 mysql
kubectl exec -ti -n rook-ceph mysql-0 bash
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
mysql> flush privileges;

# 获取 mysql cluster ip
kubectl get -n rook-ceph pod mysql-0 -o wide

# 进入 hammerdb
kubectl exec -ti -n rook-ceph hammerdb-0 bash
./hammerdbcli 

# tpc-h 测试
dbset db mysql
dbset bm tpc-h
diset connection mysql_host 10.199.1.144 # 修改为上方获取的 cluster ip
diset tpch mysql_tpch_pass password
buildschema
loadscript
vurun

# tpc-c 测试
dbset db mysql
dbset bm tpc-c
diset connection mysql_host 10.199.2.104
diset tpcc mysql_pass password
diset tpcc mysql_driver timed
diset tpcc mysql_rampup 0
diset tpcc mysql_duration 1
buildscript
loadscript
vuset vu [ 1 2 4 8 ]  # 执行时选择
vucreate
vurun
```

##### hammerdb 测试结果

```shell
#tpch
Vuser 1:Completed 1 query set(s) in 351 seconds
Vuser 1:FINISHED SUCCESS
```

```shell
# tpc-c
hammerdb>vuset vu 1
hammerdb>vucreate
hammerdb>vurun
Vuser 1:1 Active Virtual Users configured
Vuser 1:TEST RESULT : System achieved 2436 MySQL TPM at 824 NOPM
hammerdb>vudestroy

hammerdb>vuset vu 2
hammerdb>vurun
Vuser 1:2 Active Virtual Users configured
Vuser 1:TEST RESULT : System achieved 4067 MySQL TPM at 1265 NOPM
hammerdb>vudestroy

hammerdb>vuset vu 4
hammerdb>vurun
Vuser 1:4 Active Virtual Users configured
Vuser 1:TEST RESULT : System achieved 6114 MySQL TPM at 2021 NOPM
hammerdb>vudestroy

hammerdb>vuset vu 8
hammerdb>vurun
Vuser 1:8 Active Virtual Users configured
Vuser 1:TEST RESULT : System achieved 6148 MySQL TPM at 2040 NOPM
```

##### cosbench 测试过程

```shell
docker run --name cosbench -dti -p 19088:19088 -p 18088:18088 nexenta/cosbench:latest bash
docker exec -ti cosbench bash
cd cos
bash start-all.sh

# 浏览器打开 192.168.32.30:19088/controller/index.html，可以看到页面，域名部分需替换为自己节点的 ip
# ceph 集群部分需要获取 key，修改允许创建的 bucket 数量

kubectl exec -ti -n rook-ceph rook-ceph-tools-5dd4bb486d-gh9wh bash
radosgw-admin user list
radosgw-admin user modify --uid ceph-user-7dTmT9Mw max_buckets=1000000

# 以上命令需要根据环境修改 ceph-tools 容器名称和 ceph 用户名
# 修改 bucket 限制后，会回显 ak sk，复制保留下来

# 使用以上信息修改 s3 xml 文件，用于提交 cosbench 测试，密码部分可以忽略
...
  <auth type="none" config="username=ceph-user-7dTmT9Mw;password=AQCaVMdfA/ZUIBAAsmBR3jkUEU6LBYCMIyiFZw==;auth_url=http://192.168.32.30:32059"/>
  <storage type="s3" config="accesskey=DX6Z8326O1D4Z3BFRBC2;secretkey=Xz9llJeTcxaUzz62rOTejtFsSHzNdN159QeWBTZg;endpoint=http://192.168.32.30:32059;timeout=60"/>
...
```

##### cosbench 测试结果

![](/home/jing2uo/Desktop/alauda/ssd/cosbench.png)

#### case2:  metadata 使用 pmem

##### cockroach 测试结果

```shell
# bank 结果

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0         105103          350.3    613.8     12.6    570.4  15032.4 103079.2  transfer

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__result
  300.0s        0         105103          350.3    613.8     12.6    570.4  15032.4 103079.2  
```

```shell
# movr 结果

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            954            3.2      5.5      5.0     11.5     15.2     21.0  addUser

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            313            1.0      8.8      8.9     13.1     15.7     19.9  addVehicle

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            331            1.1      9.9     10.0     13.6     17.8     19.9  applyPromoCode

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            100            0.3      5.0      5.0      6.6      7.9     11.5  createPromoCode

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0            233            0.8      5.3      5.0     10.0     13.6     18.9  endRide

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0          62239          207.5      1.1      1.0      1.4      1.7     30.4  readVehicles

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0           1276            4.3     15.0     14.7     23.1     30.4     41.9  startRide

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0           3207           10.7     62.2     58.7    113.2    159.4    201.3  updateActiveRides

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__result
  300.0s        0          68653          228.8      4.4      1.1     17.8     65.0    201.3  
```

```shell
# tpcc 结果

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0              6            0.0     55.7     50.3     75.5     75.5     75.5  delivery

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0             62            0.2     31.8     31.5     39.8     44.0     54.5  newOrder

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0              4            0.0      7.9      7.9      8.4      8.4      8.4  orderStatus

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0             65            0.2     21.1     17.8     48.2    100.7    121.6  payment

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0              5            0.0     20.6     16.3     37.7     37.7     37.7  stockLevel

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__result
  300.0s        0            142            0.5     26.8     26.2     50.3    100.7    121.6  

_elapsed_______tpmC____efc__avg(ms)__p50(ms)__p90(ms)__p95(ms)__p99(ms)_pMax(ms)
  300.0s       12.4  96.4%     31.8     31.5     37.7     39.8     44.0     54.5
```

```shell
# ycsb 结果

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0       16358917        54529.4      3.5      1.2     13.6     41.9    604.0  read

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__total
  300.0s        0         858709         2862.3     12.3      8.9     30.4     75.5   1040.2  update

_elapsed___errors_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)__result
  300.0s        0       17217626        57391.8      3.9      1.4     15.2     44.0   1040.2  
```

##### hammerdb 测试结果

```shell
# tpch 
Vuser 1:Completed 1 query set(s) in 106 seconds
Vuser 1:FINISHED SUCCESS
```

```shell
# tpcc
hammerdb>vuset vu 1
hammerdb>vucreate
hammerdb>vurun
Vuser 1:1 Active Virtual Users configured
Vuser 1:TEST RESULT : System achieved 6960 MySQL TPM at 2397 NOPM
hammerdb>vudestroy

hammerdb>vuset vu 2
hammerdb>vucreate
hammerdb>vurun
Vuser 1:2 Active Virtual Users configured
Vuser 1:TEST RESULT : System achieved 11730 MySQL TPM at 3824 NOPM
hammerdb>vudestroy

hammerdb>vuset vu 4
hammerdb>vucreate
hammerdb>vurun
Vuser 1:4 Active Virtual Users configured
Vuser 1:TEST RESULT : System achieved 17514 MySQL TPM at 5717 NOPM
hammerdb>vudestroy

hammerdb>vuset vu 8
hammerdb>vucreate
hammerdb>vurun
Vuser 1:8 Active Virtual Users configured
Vuser 1:TEST RESULT : System achieved 19551 MySQL TPM at 6534 NOPM
```

##### cosbench 测试结果

![](/home/jing2uo/Desktop/alauda/meta/cosbench.png)



### 参考链接

删除 terminating 状态的 pv  https://blog.csdn.net/solaraceboy/article/details/1000405241

对象存储配置   https://zhuanlan.zhihu.com/p/107083375

ceph 用户管理 https://docs.ceph.com/en/latest/man/8/radosgw-admin/

pmem-csi安装文档 https://github.com/intel/pmem-csi/blob/devel/docs/install.md

ndctl 排错 https://docs.pmem.io/ndctl-user-guide/troubleshooting