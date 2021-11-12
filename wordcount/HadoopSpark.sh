#!/usr/bin/env bash

if [ ! -d "input" ] ; then
	echo "Downloading dataset!"
	mkdir input
	cat url.txt | while read line
	do
		(cd input
		URL=`curl -Ls -o /dev/null -w "%{url_effective}\n" "$line"`
		curl -Ls -O "$URL")
	done
	echo "Starting pseudo-distributed Hadoop daemons!"
	/usr/local/hadoop-3.3.1/sbin/start-all.sh
	echo "Setting up HDFS!"
	hdfs dfs -mkdir /user
	hdfs dfs -mkdir /user/$(whoami)
	hdfs dfs -mkdir SparkHadoop
	hdfs dfs -mkdir SparkHadoop/input
	hdfs dfs -mkdir SparkHadoop/output
	hdfs dfs -copyFromLocal input/* SparkHadoop/input
	echo "Following files copide to HDFS:"
	hdfs dfs -ls SparkHadoop/input/
	exit
fi

OLD_TIMEFORMAT="$TIMEFORMAT"
TIMEFORMAT='%3U'
