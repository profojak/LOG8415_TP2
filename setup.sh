#!/usr/bin/env bash

HADOOP=/usr/local/hadoop-3.3.1
sudo apt update
sudo apt install openjdk-8-jre-headless python3 python3-pip
pip3 install pyspark
echo '
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop-3.3.1
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HADOOP_HOME/bin:$PATH"
' >> ~/.profile
wget https://dlcdn.apache.org/hadoop/common/current/hadoop-3.3.1.tar.gz
wget https://dlcdn.apache.org/hadoop/common/current/hadoop-3.3.1.tar.gz.sha512
DIFF=$(diff <(sha512sum hadoop-3.3.1.tar.gz | cut -d " " -f 1) <(cat hadoop-3.3.1.tar.gz.sha512 | cut -d " " -f 4))
if [ "$DIFF" != "" ] ; then
	echo "SHA512 of Hadoop not matching! Aborting..."
	exit
fi
echo "SHA512 hash verified!"
sudo tar -xf hadoop-3.3.1.tar.gz -C /usr/local/
rm hadoop-3.3.1.tar.gz hadoop-3.3.1.tar.gz.sha512
echo '
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop-3.3.1
' >> $HADOOP/etc/hadoop/hadoop-env.sh
source ~/.profile
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>

    <property>
        <name>hadoop.tmp.dir</name>
        <value>/var/lib/hadoop</value>
    </property>
</configuration>
' > $HADOOP/etc/hadoop/core-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
' > $HADOOP/etc/hadoop/hdfs-site.xml
echo "KEEP DEFAULT VALUES, PRESS ENTER!"
ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa $(whoami)@localhost
sudo mkdir /var/lib/hadoop
sudo chmod 777 /var/lib/hadoop
hdfs namenode -format
echo "SPARK AND HADOOP READY! START HADOOP DEAMONS WITH source ~/.profile & /usr/local/hadoop-3.3.1/sbin/start-all.sh"
