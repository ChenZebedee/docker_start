# 指定基于哪个镜像创建docker
FROM centos:scala

# 切换工作目录
WORKDIR /opt/

# zookeeper-3.4.13
COPY ./somefile/zookeeper.tar.gz /opt/
RUN tar -zxf zookeeper.tar.gz
RUN echo "export ZOOKEEPER_HOME=/opt/zookeeper" >> /etc/profile
RUN echo "export PATH=\${PATH}:\${ZOOKEEPER_HOME}/bin" >> /etc/profile

# hadoop-3.1.1
COPY ./somefile/hadoop.tar.gz /opt/
RUN tar -zxf hadoop.tar.gz
RUN echo "export HADOOP_HOME=/opt/hadoop" >> /etc/profile
RUN echo "export PATH=\${PATH}:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin" >> /etc/profile
RUN cat /etc/profile


# add user hadoop
RUN useradd hadoop
RUN echo '123456' | passwd --stdin hadoop
RUN mkdir -p /home/hadoop/.ssh
COPY ./somefile/id_rsa /home/hadoop/.ssh
COPY ./somefile/id_rsa.pub /home/hadoop/.ssh
COPY ./somefile/config /home/hadoop/.ssh
WORKDIR /home/hadoop/.ssh
RUN ls -l
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/authorized_keys
RUN chmod 600 /home/hadoop/authorized_keys
RUN chown -R hadoop:hadoop /home/hadoop/

# add ssh key
RUN mkdir /root/.ssh
COPY ./somefile/id_rsa /root/.ssh/
COPY ./somefile/id_rsa.pub /root/.ssh/
COPY ./somefile/config /root/.ssh/
WORKDIR /root/.ssh/
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys


RUN chown -R hadoop:hadoop /opt/hadoop
RUN chown -R hadoop:hadoop /opt/zookeeper

# sshd -D
ENTRYPOINT /usr/sbin/sshd -D

WORKDIR /

