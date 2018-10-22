#!/bin/bash

# 定义用于拷贝配置文件，分配ip地址的函数
cp_config(){
    #docker exec ${1}${2} cp /home/data/dragon/cluster-build/hadoop-env.sh /opt/hadoop-3.1.1/etc/hadoop/
    #docker exec ${1}${2} cp /home/data/dragon/cluster-build/mapred-env.sh /opt/hadoop-3.1.1/etc/hadoop/
    #docker exec ${1}${2} cp /home/data/dragon/cluster-build/yarn-env.sh /opt/hadoop-3.1.1/etc/hadoop/
    #docker exec ${1}${2} cp /home/data/dragon/cluster-build/core-site.xml /opt/hadoop-3.1.1/etc/hadoop/
    #docker exec ${1}${2} cp /home/data/dragon/cluster-build/hdfs-site.xml /opt/hadoop-3.1.1/etc/hadoop/
    #docker exec ${1}${2} cp /home/data/dragon/cluster-build/yarn-site.xml /opt/hadoop-3.1.1/etc/hadoop/
    #docker exec ${1}${2} cp /home/data/dragon/cluster-build/mapred-site.xml /opt/hadoop-3.1.1/etc/hadoop/
    docker exec ${1}${2} cp /home/data/dragon/cluster-build/workers /opt/hadoop/etc/hadoop/

    docker exec ${1}${2} cp /home/data/dragon/cluster-build/hosts /etc
    pipework br0 ${1}${2} 192.168.5.$((${3}+${2}-1))/24
}

# 删除上次创建的hosts配置
test -e hosts&& rm hosts

# 定义集群数量和集群起始ip分配地址
declare -i zk_num=3
declare -i zk_ipbase=2
declare -i rm_num=2
declare -i rm_ipbase=20
declare -i nn_num=2
declare -i nn_ipbase=40
declare -i dn_num=3
declare -i dn_ipbase=60

# hosts configration
echo 127.0.0.1 localhost.localdomain localhost >> hosts
for ((i=1; i<=${zk_num}; i=i+1 ))
do
    echo 192.168.5.$((${zk_ipbase}+${i}-1))    zookeeper${i} >> hosts
done
for ((i=1; i<=${rm_num}; i=i+1 ))
do
    echo 192.168.5.$((${rm_ipbase}+${i}-1))    resourcemanager${i} >> hosts
done
for ((i=1; i<=${nn_num}; i=i+1 ))
do
    echo 192.168.5.$((${nn_ipbase}+${i}-1))    namenode${i} >> hosts
done
for ((i=1; i<=${dn_num}; i=i+1 ))
do
    echo 192.168.5.$((${dn_ipbase}+${i}-1))    datanode${i} >> hosts
done

# zookeeper
for ((i=1; i<=${zk_num}; i=i+1 ))
do
    docker run -d -h zookeeper${i} --name=zookeeper${i} -v /home/data/dragon/cluster-build:/home/data/dragon/cluster-build bigdata:ha /usr/bin/sshd -D
    docker exec zookeeper${i} mkdir /opt/zookeeper/data
    docker exec zookeeper${i} /home/data/dragon/cluster-build/myid.sh ${i}
    docker exec zookeeper${i} chown -R hadoop:hadoop /opt/zookeeper
    cp_config 'zookeeper' ${i} ${zk_ipbase}
done

# resourcemanager
# workers 文件在启动集群时会用到
test -e workers && rm workers
for ((i=1; i<=${rm_num}; i=i+1 ))
do
    echo resourcemanager${i} >> workers
done
for ((i=1; i<=${rm_num}; i=i+1 ))
do
    docker run -d -h resourcemanager${i} --name=resourcemanager${i} -v /home/data/dragon/cluster-build:/home/data/dragon/cluster-build bigdata:ha /usr/bin/sshd -D
    docker exec resourcemanager${i} cp /home/data/dragon/cluster-build/workers /opt/hadoop/etc/hadoop/
    cp_config 'resourcemanager' ${i} ${rm_ipbase}
done

# namenode
for ((i=1; i<=${nn_num}; i=i+1 ))
do
    docker run -d -h namenode${i} --name=namenode${i} -v /home/data/dragon/cluster-build:/home/data/dragon/cluster-build bigdata:ha /usr/bin/sshd -D
    cp_config 'namenode' ${i} ${nn_ipbase}
done

# datanode
test -e workers && rm workers
for ((i=1; i<=${dn_num}; i=i+1 ))
do
    echo datanode${i} >> workers
done
for ((i=1; i<=${dn_num}; i=i+1 ))
do
    docker run -d -h datanode${i} --name=datanode${i} -v /home/data/dragon/cluster-build:/home/data/dragon/cluster-build bigdata:ha /usr/bin/sshd -D 
    docker exec datanode${i} cp /home/data/dragon/cluster-build/workers /opt/hadoop/etc/hadoop/
    cp_config 'datanode' ${i} ${dn_ipbase}
done
