 docker run -d -p 10023:22 -p 50070:50700 -p 19888:19888 -p 8088:8088 -h master --name master centos:hadoop /usr/sbin/sshd -D
 docker run -d -p 10024:22 -h slave1 --name slave1 centos:hadoop /usr/sbin/sshd -D
 docker run -d -p 10026:22 -h slave3 --name slave3 centos:hadoop /usr/sbin/sshd -D
 docker run -d -p 10025:22 -h slave2 --name slave2 centos:hadoop /usr/sbin/sshd -D
